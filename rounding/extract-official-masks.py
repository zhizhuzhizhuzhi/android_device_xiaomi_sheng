#!/usr/bin/env python3
"""Losslessly extract AOSP single-corner masks from the official Sheng PNG strips.
Only selects original RGBA pixels and reverses bottom rows for AOSP's top-left
base orientation. No interpolation, thresholding, curve redraw or AI asset.
"""
from pathlib import Path
import argparse,struct,zlib,json,hashlib,zipfile

def digest(b):return hashlib.sha256(b).hexdigest()
def decode(data):
    assert data[:8]==b'\x89PNG\r\n\x1a\n'
    off=8;compressed=b'';info=None;palette=None;transparency=b''
    while off<len(data):
        size=struct.unpack('>I',data[off:off+4])[0];kind=data[off+4:off+8];payload=data[off+8:off+8+size]
        crc=struct.unpack('>I',data[off+8+size:off+12+size])[0];assert zlib.crc32(kind+payload)&0xffffffff==crc
        if kind==b'IHDR':info=struct.unpack('>IIBBBBB',payload)
        if kind==b'IDAT':compressed+=payload
        if kind==b'PLTE':palette=payload
        if kind==b'tRNS':transparency=payload
        off+=12+size
    w,h,bits,color,comp,filt,interlace=info;assert bits==8 and color in (3,6) and (comp,filt,interlace)==(0,0,0),info
    raw=zlib.decompress(compressed);channels=4 if color==6 else 1;stride=w*channels;assert len(raw)==h*(stride+1);rows=[];prev=bytes(stride)
    for y in range(h):
        base=y*(stride+1);mode=raw[base];src=raw[base+1:base+1+stride];out=bytearray(stride)
        for x,v in enumerate(src):
            a=out[x-channels]if x>=channels else 0;b=prev[x];c=prev[x-channels]if x>=channels else 0
            if mode==0:q=0
            elif mode==1:q=a
            elif mode==2:q=b
            elif mode==3:q=(a+b)//2
            elif mode==4:
                p=a+b-c;pa,pb,pc=abs(p-a),abs(p-b),abs(p-c);q=a if pa<=pb and pa<=pc else b if pb<=pc else c
            else:raise ValueError(mode)
            out[x]=(v+q)&255
        prev=out
        if color==3:
            assert palette is not None
            expanded=bytearray()
            for idx in out:
                expanded.extend(palette[idx*3:idx*3+3]);expanded.append(transparency[idx] if idx<len(transparency) else 255)
            rows.append(bytes(expanded))
        else:rows.append(bytes(out))
    return w,h,rows

def encode(w,h,rows):
    def chunk(k,b):return struct.pack('>I',len(b))+k+b+struct.pack('>I',zlib.crc32(k+b)&0xffffffff)
    return b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',w,h,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(b''.join(b'\0'+row for row in rows),9))+chunk(b'IEND',b'')

def main():
    p=argparse.ArgumentParser();p.add_argument('--stock-root',type=Path,required=True);p.add_argument('--device-root',type=Path,required=True);a=p.parse_args()
    apk=a.stock_root/'product/overlay/DevicesOverlay.apk';framework=a.stock_root/'product/overlay/DevicesAndroidOverlay.apk'
    output=a.device_root/'overlay/SystemUIOverlaySheng/res/drawable-nodpi';output.mkdir(exist_ok=True)
    archive=a.device_root/'rounding/official';archive.mkdir(parents=True,exist_ok=True)
    audit={'stock_apk':'product/overlay/DevicesOverlay.apk','stock_apk_sha256':digest(apk.read_bytes()),'framework_apk':'product/overlay/DevicesAndroidOverlay.apk','framework_apk_sha256':digest(framework.read_bytes()),'official_framework_radius_px':66,'mask_tile_px':208,'density':'nodpi, no density resampling','files':[]}
    assert audit['stock_apk_sha256']=='300e3439a37c7c00d340294f8f6d2e736167e8869635cbcdfe61fbeaabc51236'
    with zipfile.ZipFile(apk)as z:
        for edge in ['top','bottom']:
            entry='res/drawable-anydpi-v21/screen_round_corner_'+edge+'.png';data=z.read(entry);(archive/('screen_round_corner_'+edge+'.png')).write_bytes(data)
            w,h,rows=decode(data);assert (w,h)==(2032,208)
            region=[row[:208*4] for row in rows]
            if edge=='bottom':region.reverse()
            derived=encode(208,208,region);dw,dh,decoded=decode(derived);assert (dw,dh)==(208,208)and decoded==region
            # The full-strip center must be transparent: no center/other-corner content was silently lost.
            assert all(all(v==0 for v in row[208*4+3:(w-208)*4:4])for row in rows)
            alpha=b''.join(row[3::4]for row in region);partial=sum(0<x<255 for x in alpha);assert partial>100
            dest=output/('rounded_corner_'+edge+'.png');dest.write_bytes(derived)
            audit['files'].append({'entry':entry,'source_sha256':digest(data),'output':str(dest.relative_to(a.device_root)),'output_sha256':digest(derived),'pixel_rgba_sha256':digest(b''.join(region)),'crop':[0,0,208,208],'vertical_flip':edge=='bottom','partial_alpha_pixels':partial,'source_region_pixels_equal':True})
    (a.device_root/'rounding/provenance.json').write_text(json.dumps(audit,indent=2)+'\n');print(json.dumps(audit,indent=2))
if __name__=='__main__':main()
