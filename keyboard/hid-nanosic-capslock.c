// SPDX-License-Identifier: GPL-2.0-only
/* Copyright (C) 2026 The AOSPA Project */
#include <linux/hid.h>
#include <linux/input.h>
#include <linux/i2c.h>
#include <linux/of.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/workqueue.h>

struct nanosic_capslock {
    struct hid_device *hid;
    struct i2c_client *client;
    struct work_struct work;
    int (*original_event)(struct input_dev *, unsigned int, unsigned int, int);
    bool enabled;
    bool stopping;
};

static void nanosic_capslock_work(struct work_struct *work)
{
    struct nanosic_capslock *caps = container_of(work, struct nanosic_capslock, work);
    u8 *wire, *command;
    int i, ret;

    if (READ_ONCE(caps->stopping))
        return;
    wire = kzalloc(67, GFP_KERNEL);
    if (!wire) {
        hid_err(caps->hid, "Allocating Caps Lock command failed\n");
        return;
    }
    wire[0] = 0x5c;
    command = wire + 1;
    command[0] = 0x32;
    command[2] = 0x4e;
    command[3] = 0x31;
    command[4] = 0x80;
    command[5] = 0x38;
    command[6] = 0x2e;
    command[7] = 1;
    command[8] = READ_ONCE(caps->enabled) ? 0xfd : 0xfc;
    for (i = 2; i < 9; i++)
        command[9] += command[i];
    ret = i2c_master_send(caps->client, wire, 67);
    if (ret != 67)
        hid_err(caps->hid, "Caps Lock output failed: %d\n", ret);
    else
        hid_info(caps->hid, "Caps Lock output state=%u\n", command[8] == 0xfd);
    kfree(wire);
}

static int nanosic_capslock_event(struct input_dev *input, unsigned int type,
                                 unsigned int code, int value)
{
    struct hid_device *hid = to_hid_device(input->dev.parent);
    struct nanosic_capslock *caps = hid_get_drvdata(hid);

    if (type != EV_LED || code != LED_CAPSL)
        return caps->original_event ? caps->original_event(input, type, code, value) : -1;
    WRITE_ONCE(caps->enabled, value != 0);
    if (!READ_ONCE(caps->stopping))
        schedule_work(&caps->work);
    return 0;
}

static int nanosic_capslock_input_configured(struct hid_device *hid,
                                           struct hid_input *hidinput)
{
    struct nanosic_capslock *caps = hid_get_drvdata(hid);

    if (test_bit(EV_LED, hidinput->input->evbit) &&
        test_bit(LED_CAPSL, hidinput->input->ledbit)) {
        caps->original_event = hidinput->input->event;
        hidinput->input->event = nanosic_capslock_event;
    }
    return 0;
}

static void nanosic_capslock_put_client(void *data)
{
    struct i2c_client *client = data;
    put_device(&client->dev);
}

static int nanosic_capslock_probe(struct hid_device *hid,
                                 const struct hid_device_id *id)
{
    struct nanosic_capslock *caps;
    struct device_node *node;
    int ret;

    caps = devm_kzalloc(&hid->dev, sizeof(*caps), GFP_KERNEL);
    if (!caps)
        return -ENOMEM;
    node = of_find_compatible_node(NULL, NULL, "nanosic,803");
    if (!node)
        return -ENODEV;
    caps->client = of_find_i2c_device_by_node(node);
    of_node_put(node);
    if (!caps->client)
        return -EPROBE_DEFER;
    ret = devm_add_action_or_reset(&hid->dev, nanosic_capslock_put_client, caps->client);
    if (ret)
        return ret;
    caps->hid = hid;
    INIT_WORK(&caps->work, nanosic_capslock_work);
    hid_set_drvdata(hid, caps);
    /* Preserve hid-generic's report/application grouping for the OEM transport. */
    hid->quirks |= HID_QUIRK_INPUT_PER_APP;
    ret = hid_parse(hid);
    if (ret)
        return ret;
    ret = hid_hw_start(hid, HID_CONNECT_DEFAULT);
    if (ret) {
        cancel_work_sync(&caps->work);
        return ret;
    }
    schedule_work(&caps->work);
    return 0;
}

static void nanosic_capslock_remove(struct hid_device *hid)
{
    struct nanosic_capslock *caps = hid_get_drvdata(hid);

    WRITE_ONCE(caps->stopping, true);
    hid_hw_stop(hid);
    cancel_work_sync(&caps->work);
}

#ifdef CONFIG_PM
static int nanosic_capslock_resume(struct hid_device *hid)
{
    struct nanosic_capslock *caps = hid_get_drvdata(hid);

    schedule_work(&caps->work);
    return 0;
}
#endif

static const struct hid_device_id nanosic_capslock_devices[] = {
    { HID_DEVICE(BUS_VIRTUAL, HID_GROUP_GENERIC, 0x15d9, 0x00a3) },
    { }
};
MODULE_DEVICE_TABLE(hid, nanosic_capslock_devices);

static struct hid_driver nanosic_capslock_driver = {
    .name = "nanosic-capslock",
    .id_table = nanosic_capslock_devices,
    .probe = nanosic_capslock_probe,
    .remove = nanosic_capslock_remove,
    .input_configured = nanosic_capslock_input_configured,
#ifdef CONFIG_PM
    .resume = nanosic_capslock_resume,
    .reset_resume = nanosic_capslock_resume,
#endif
};
module_hid_driver(nanosic_capslock_driver);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Sheng Nanosic Caps Lock HID output translation");
