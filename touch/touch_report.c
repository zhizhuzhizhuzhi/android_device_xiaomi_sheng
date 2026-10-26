// SPDX-License-Identifier: Apache-2.0
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char **argv) {
    const char *library = getenv("SHENG_TOUCHREPORT_LIBRARY");
    if (!library) library = "libtouchreport.so";
    void *handle = dlopen(library, RTLD_NOW | RTLD_LOCAL);
    if (!handle) { fprintf(stderr, "touch_report: %s\n", dlerror()); return 1; }
    int (*entry)(int, char **) = (int (*)(int, char **))dlsym(handle, "thp_daemon_main");
    if (!entry) { fprintf(stderr, "touch_report: %s\n", dlerror()); return 1; }
    return entry(argc, argv);
}
