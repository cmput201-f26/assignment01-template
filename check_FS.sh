#!/bin/bash

# *-------------------- `check.sh` Exit Codes --------------------* #
#  0 : Success              :   Student passes all tests
#  1 : Student error        :   `diff` fail, timeouts, etc
#  2 : Development error    :   Missing testcase dirs, missing output files, etc

# Configuration
compilation_flags="-Wall -Werror -std=c99"
required_source_files=("assg.c")
allowed_libraries=("^(stdio\.h|stdlib\.h|stdbool\.h|stdint\.h|string\.h)$")
time_limit=30

# Directories
source_dir="./src"
testcases_dir="./FS_Testcases"

# File postfixes
input_postfix="-input.txt"
stdin_postfix="-stdin.txt"
output_postfix="-output.txt"
stdout_postfix="-stdout.txt"
student_postfix="-student.txt"
student_stdout_postfix="-student_stdout.txt"

# Logging functions
width=$(tput cols);
log()     { printf "\033[00m[CHECK] %s\033[0m\n" "$1"; }
info()    { printf "\033[33m[CHECK] %s\033[0m\n" "$1"; }
success() { printf "\033[32m[CHECK] %s\033[0m\n" "$1"; }
warning() { printf "\033[35m[CHECK] Warning: %s\033[0m\n" "$1"; }
br()      { break=$(printf "%*s" "$((width-8))" "" | tr " " "-"); log "$break"; }
error() {
    printf "\033[31m[CHECK] Error: %s\033[0m\n" "$1";
    br; info "END: Check failed."; br; echo;
    exit "$2";
}

echo; br; success "START";

# Check directories
if [ ! -d "$testcases_dir" ]; then
    error "Expected test cases directory '$testcases_dir' does not exist." 2
fi
if [ ! -d "$source_dir" ]; then
    error "Expected source directory '$source_dir' does not exist." 1
fi

# Setup List File
LIST_FILE="${testcases_dir}/list_file.txt"
log "Generating list file: $LIST_FILE"
ls simplified_schedules/*.txt > "$LIST_FILE" 2>/dev/null

# Track overall success
overall_fail=0

# Main processing loop
for source_file in "${required_source_files[@]}"; do
    br
    source_path="$source_dir/$source_file"
    exe_path="./arc_analyzer"
    
    if [ ! -e "$source_path" ]; then
        error "Required file '$source_path' not found." 1
    fi

    log "Checking '$source_file'..."

    # Check for extra includes
    extra_include_count=$(
        grep '^\s*#\s*include\b' "$source_path" | \
        sed -E 's/^\s*#\s*include\s*[<"]([^">]+)[">].*/\1/' | \
        grep -Ev "${allowed_libraries[0]}" | \
        wc -l
    )
    if [[ "$extra_include_count" -ne 0 ]]; then
        extra_includes=$(
            grep '^\s*#\s*include\b' "$source_path" | \
            sed -E 's/^\s*#\s*include\s*[<"]([^">]+)[">].*/\1/' | \
            grep -Ev "${allowed_libraries[0]}"
        )
        warning "Banned libraries found in '$source_path': $extra_includes"
        overall_fail=1
    fi

    # Compile
    if gcc ${compilation_flags} "$source_path" -o "$exe_path"; then
        success "'$source_path' compiled successfully."
    else
        error "Compilation of '$source_path' failed." 1
    fi

    # Iterate over every input file
    for input_path in "$testcases_dir"/*"$input_postfix"; do
        # Skip if no files match the pattern
        [ -e "$input_path" ] || continue

        log ""
        
        # Determine paths
        stdin_path=${input_path/"$input_postfix"/"$stdin_postfix"}
        output_path=${input_path/"$input_postfix"/"$output_postfix"}
        stdout_path=${input_path/"$input_postfix"/"$stdout_postfix"}
        student_output_path=${input_path/"$input_postfix"/"$student_postfix"}
        student_stdout_path=${input_path/"$input_postfix"/"$student_stdout_postfix"}

        if [[ ! -e $output_path ]]; then
            info "Missing expected output file: '$output_path'. Skipping test case."
            continue
        fi

        # Prepare stdin
        if [[ ! -e $stdin_path ]]; then
            stdin_source="/dev/null"
        else
            stdin_source="$stdin_path"
        fi

        log "Testing using '$(basename "$input_path")'..."
        rm -f output.txt
        
        # Run the program - Only capture stdout
        timeout "$time_limit" "$exe_path" "$LIST_FILE" "$input_path" < "$stdin_source" > "$student_stdout_path" 2>/dev/null
        
        exit_code=$?
        if [ $exit_code -eq 124 ]; then
            warning "Test case timed out."
            overall_fail=1
        elif [ $exit_code -ne 0 ]; then
            warning "Program exited with non-zero code $exit_code."
            # We don't set overall_fail here as some logic errors allow non-zero exits
        fi

        # Compare stdout (Ensure file exists before diff)
        if [[ -e $stdout_path ]]; then
            if [ ! -f "$student_stdout_path" ]; then touch "$student_stdout_path"; fi
            if diff -u "$stdout_path" "$student_stdout_path" > /dev/null; then
                success "stdout matches expected."
            else
                warning "stdout does not match expected."
                overall_fail=1
            fi
        fi

        # Compare output.txt (Ensure file exists before diff)
        if [ -f "output.txt" ]; then
            mv output.txt "$student_output_path"
        else
            # Create an empty file if the student's program didn't make output.txt
            touch "$student_output_path"
        fi

        if diff -u "$output_path" "$student_output_path" > /dev/null; then
            success "output.txt matches expected."
        else
            warning "output.txt does not match expected."
            overall_fail=1
        fi
    done
    
    # Cleanup executable
    rm -f "$exe_path"
done

# Final Summary Exit
br
if [ $overall_fail -eq 0 ]; then
    success "END: All test cases passed!"
    echo
    exit 0
else
    printf "\033[31m[CHECK] END: Some test cases failed. Review warnings above.\033[0m\n"
    echo
    exit 1
fi

