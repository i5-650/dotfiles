function decrypt_file
    if test (count $argv) -eq 0
        echo "Usage: decrypt_file <filename.enc>"
        return 1
    end

    set input_file $argv[1]

    if not test -f $input_file
        echo "File not found: $input_file"
        return 1
    end

    if not string match -r '\.enc$' -- $input_file
        echo "File does not have a .enc extension: $input_file"
        return 1
    end

    set output_file (string replace -r '\.enc$' '' $input_file)

    openssl enc -aes-256-cbc -d -in $input_file -out $output_file
end

