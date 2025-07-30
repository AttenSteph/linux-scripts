#!/bin/bash

# Define a helper function to print section headers with clear formatting
section() {
    echo -e "\n=== $1 ==="
}

# Display physical volumes (PVs)
# We use pvs with custom output fields (pv_name, pv_size, vg_name) and pipe it into awk
# Awk formats the output for readability with aligned columns.
section "Physical Volumes (PVs)"
pvs --noheadings --separator '|' -o pv_name,pv_size,vg_name | awk -F'|' '
{
  # Print physical volume name, size, and associated volume group
  printf "PV: %-20s Size: %-8s VG: %s\n", $1, $2, $3
}'

# Display volume groups (VGs) and highlight if there is free space
# We calculate free space and add a note if it is greater than zero.
section "Volume Groups (VGs)"
vgs --noheadings --separator '|' -o vg_name,vg_size,vg_free | awk -F'|' '
{
  free_str = $3;          # Free space string with unit (e.g., 23.47G)
  free_val = free_str;    # Copy value for numeric processing
  gsub("G", "", free_val); # Remove the G suffix for numeric comparison
  if (free_val+0 > 0) {
    # If there is free space, print an alert message
    printf "VG: %-20s Size: %-8s Free: %-8s  <-- Potential unused space!\n", $1, $2, $3;
  } else {
    # Otherwise, print normal line
    printf "VG: %-20s Size: %-8s Free: %-8s\n", $1, $2, $3;
  }
}'

# Display logical volumes (LVs)
# We show LV details including associated VG, name, size, and device path.
section "Logical Volumes (LVs)"
lvs --noheadings --separator '|' -o vg_name,lv_name,lv_size,lv_path | awk -F'|' '
{
  printf "VG: %-20s LV: %-20s Size: %-8s Path: %s\n", $1, $2, $3, $4
}'

# Show hierarchy view: which PVs and LVs belong to each VG
# This loops through each volume group and prints associated PVs and LVs.
section "Hierarchy"
vgs --noheadings -o vg_name,vg_free | while read line; do
  VG=$(echo $line | awk '{print $1}')      # Extract VG name
  VG_FREE=$(echo $line | awk '{print $2}') # Extract free space in VG

  # Print VG with its free space value
  echo "Volume Group: $VG (Free: $VG_FREE)"

  # List physical volumes belonging to this VG
  pvs --noheadings -o pv_name,vg_name | awk -v VG=$VG '$2==VG {print "  PV -> "$1}'

  # List logical volumes belonging to this VG
  lvs --noheadings -o lv_name,vg_name | awk -v VG=$VG '$2==VG {print "  LV -> "$1}'
done

# Provide instructions to the operator on how to extend a logical volume safely
# The note explains using lvextend and the correct follow-up command depending on filesystem type.
echo -e "\nNOTE: If free space is shown above, you can extend a logical volume with:\n"
echo -e "  sudo lvextend -l +100%FREE /dev/<vg_name>/<lv_name>"
echo -e "Then resize the filesystem (detect type first):\n"
echo -e "  For ext4: sudo resize2fs /dev/<vg_name>/<lv_name>"
echo -e "  For xfs:  sudo xfs_growfs /"
