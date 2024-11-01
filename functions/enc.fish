function enc
    if test (count $argv) -eq 0
        echo "Usage: encrypt_file <filename>"
        return 1
    end

    set input_file $argv[1]

    if not test -f $input_file
        echo "File not found: $input_file"
        return 1
    end

    set output_file "$input_file.enc"

    openssl enc -aes-256-cbc -salt -in $input_file -out $output_file
end

