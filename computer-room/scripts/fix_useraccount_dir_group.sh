# Find all directories in /home where group is "users"
for userdir in /home/*; do
    username=$(basename "$userdir")
    
    # Check if directory belongs to "users" group
    if [ "$(stat -c %G "$userdir")" = "users" ]; then
        echo "Processing $username..."
        
        # Create group with same name as user if it doesn't exist
        if ! getent group "$username" > /dev/null; then
            echo "Creating group $username"
            groupadd "$username"
        fi
        
        # Add user to their own group
        usermod -a -G "$username" "$username"
        
        # Change group ownership of home directory
        chown -R "$username:$username" "$userdir"
        
        echo "Done processing $username"
    else
	echo "$username already has its group and its home is ok"
    fi
    #read
done
