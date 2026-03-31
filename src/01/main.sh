if ! [ $1 ]; then
    echo "Input error. Zero arguments"
elif [[ $1 =~ ^[0-9]+$ ]]; then
    echo "Input error. Argument must be a string"
else
    echo $1
fi