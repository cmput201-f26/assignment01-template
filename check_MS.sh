#!/bin/bash

# *-------------------- `check_MS.sh` Exit Codes --------------------* #
#  0 : Success
#  1 : Student error
#  2 : Development error

# Configuration
compilation_flags="-Wall -Werror -std=c99"
required_source_files=("assg.c")
allowed_libraries=("^(stdio\.h|stdlib\.h|stdbool\.h|stdint\.h|string\.h)$")
time_limit=10

# Directories
source_dir="./src"
testcases_dir="./MS_Testcases"

# File postfixes
input_postfix="-input.txt"
list_postfix="-list.txt"
output_postfix="-output.txt"
student_postfix="-student.txt"

# Logging functions
width=$(tput cols);
log()     { printf "\033[00m[CHECK-MS] %s\033[0m\n" "$1"; }
info()    { printf "\033[33m[CHECK-MS] %s\033[0m\n" "$1"; }
success() { printf "\033[32m[CHECK-MS] %s\033[0m\n" "$1"; }
warning() { printf "\033[35m[CHECK-MS] Warning: %s\033[0m\n" "$1"; }
br()      { break=$(printf "%*s" "$((width-8))" "" | tr " " "-"); log "$break"; }
error() {
    printf "\033[31m[CHECK-MS] Error: %s\033[0m\n" "$1";
    br; info "END: Check failed."; br; echo;
    exit "$2";
}

echo; br; success "START MILESTONE CHECK";

# Check directories
if [ ! -d "$testcases_dir" ]; then
    error "Expected test cases directory '$testcases_dir' does not exist." 2
fi
if [ ! -d "$source_dir" ]; then
    error "Expected source directory '$source_dir' does not exist." 1
fi

# Main processing loop
for source_file in "${required_source_files[@]}"; do
    br
    source_path="$source_dir/$source_file"
    exe_path="./arc_analyzer_ms"
    
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
        error "Banned libraries found in '$source_path'. Found: $extra_includes" 1
    fi

    # Compile
    if gcc ${compilation_flags} "$source_path" -o "$exe_path"; then
        success "'$source_path' compiled successfully."
    else
        error "Compilation of '$source_path' failed." 1
    fi

    # Iterate over every list file
    for list_path in "$testcases_dir"/*"$list_postfix"; do
        log ""
        
        # Determine paths
        input_path=${list_path/"$list_postfix"/"$input_postfix"}
        output_path=${list_path/"$list_postfix"/"$output_postfix"}
        student_output_path=${list_path/"$list_postfix"/"$student_postfix"}

        if [[ ! -e $output_path ]]; then
            info "Missing output file: '$output_path'. Skipping test case."
            continue
        fi

        log "Testing using list '$list_path'..."
        
        # Run the program and capture stdout
        timeout "$time_limit" "$exe_path" "$list_path" > "$student_output_path" 2>&1
        
        exit_code=$?
        if [ $exit_code -eq 124 ]; then
            error "Program timed out." 1
        elif [ $exit_code -ne 0 ]; then
            error "Program exited with non-zero code $exit_code." 1
        else
            success "Program terminated successfully under the time limit."        
        fi

        if diff -u "$output_path" "$student_output_path"; then
            success "Output matches expected."
        else
            error "Output does not match expected for milestone. Check diff above." 1
        fi
    done
    
    # Cleanup executable
    rm -f "$exe_path"
done

# Ending message
br; success "END: Milestone Passed!"; br; echo;
