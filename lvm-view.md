# LVM Volume Overview Script

This script provides a clear, text-based overview of LVM (Logical Volume Manager) configuration on a Linux system. It displays physical volumes (PVs), volume groups (VGs), logical volumes (LVs), and highlights unused space within VGs. It also provides inline guidance for extending volumes safely.

---

## Features

* Lists PVs, VGs, and LVs with sizes and hierarchy.
* Highlights free (unallocated) space in VGs.
* Outputs a hierarchical mapping of PVs and LVs within each VG.
* Provides on-screen instructions to extend logical volumes and resize filesystems.

---

## Requirements

* Linux system with LVM2 installed (common on most modern distributions).
* Tools used: `pvs`, `vgs`, `lvs`, `awk`.
* Root or sudo privileges to access LVM metadata.

---

## Usage

1. Save the script to a file, for example `lvm-script.sh`.

2. Make it executable:

   ```bash
   chmod +x lvm-script.sh
   ```

3. Run as root or with sudo:

   ```bash
   sudo ./lvm-script.sh
   ```

---

## Sample Output

```text
=== Physical Volumes (PVs) ===
PV: /dev/sda3            Size: 47G      VG: ubuntu-vg

=== Volume Groups (VGs) ===
VG: ubuntu-vg            Size: 47G      Free: 23G   <-- Potential unused space!

=== Logical Volumes (LVs) ===
VG: ubuntu-vg            LV: ubuntu-lv  Size: 23G   Path: /dev/ubuntu-vg/ubuntu-lv

=== Hierarchy ===
Volume Group: ubuntu-vg (Free: 23G)
  PV -> /dev/sda3
  LV -> ubuntu-lv
```

---

## Extending a Logical Volume

When free space is indicated in the output:

1. Extend the logical volume using all free space:

   ```bash
   sudo lvextend -l +100%FREE /dev/<vg_name>/<lv_name>
   ```

2. Resize the filesystem (detect type first):

   * For **ext4**:

     ```bash
     sudo resize2fs /dev/<vg_name>/<lv_name>
     ```

   * For **XFS**:

     ```bash
     sudo xfs_growfs /
     ```

---

## Notes

* Ensure backups or snapshots before resizing.
* Script does not modify LVM state; it is purely informational.
* Works well in environments without GUI tools (SSH, recovery console).
