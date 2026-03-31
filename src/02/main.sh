./getInfo.sh
echo "Do you want to save data?"
read answ;
if ! [[ $answ == "Y" || $answ == "y" ]]; then 
echo "not sUre"
else
   filename=$(date +"%d_%m_%y_%H_%M_%S")
   touch "$filename.status"
   bash ./getInfo.sh > "$filename.status"
fi