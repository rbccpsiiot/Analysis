#for device in "loader" "screenprinter_vaf" "pickandplace1" "pickandplace2" "reflowoven_vaf" "bakingoven1" "bakingoven2"


rawfile="../../../data/raw/raw.csv"

fline=$(head -1 $rawfile)
for dev in "loader" "screenprinter_plus_vaf" "reflowoven_vaf" "pickandplace2"
do
	device="../../../data/interim/$dev"
        echo "Grepping.... $device"
        grep $dev $rawfile > temp
	echo "Sorting... $device"
        sort -t, -nk2 temp -o "$device.csv"
        rm temp
	sed -i "1i $fline" "$device.csv"
done
