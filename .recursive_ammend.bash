#!/bin/bash

for filename in ./ga_installfest/.*.bash; do
	# chmod +x "$filename"

	echo "#!/bin/bash" >> "$filename"
	echo "$filename ammended"
done