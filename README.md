# Assignment 1 - C Fundamentals, Formatted I/O, Expressions, File I/O, Program Arguments, Selection Statements, Loops, Arrays, Basic Types



## Arc Card Analyzer
Congratulations on your new role as a Junior Software Engineer for the **Simplemonton Transit Authority (STA)**! Our city has recently transitioned to the "Arc Card" electronic fare system. While the hardware is working, our data analytics team is struggling to make sense of the raw tap records. 

Your mission is to develop the **Arc Card Analyzer**, a robust C program that can reconstruct a rider's journey. By matching tap records with our official route schedules, your program will produce a clean, chronological summary of every trip a rider took.

## Table of contents

- [**Getting Started (Lab Setup)**](#getting-started-lab-setup)
    - [Important Distinctions between Unix and Windows](#important-distinctions-between-unix-and-windows)
    - [Part 1 - Setting up SSH](#part-1---setting-up-ssh)
        - [Generating an SSH Key](#generating-an-ssh-key)
        - [Setting up the SSH Configuration](#setting-up-the-ssh-configuration)
        - [Copying the SSH Key](#copying-the-ssh-key)
    - [Part 2 - Working on a Lab Machine through SSH](#part-2---working-on-a-lab-machine-through-ssh)
        - [Connecting](#connecting)
        - [The File System](#the-file-system)
        - [Moving Files between Machines Using scp](#moving-files-between-machines-using-scp)
    - [Part 3 - GitHub setup on Lab Machine](#part-3---github-setup-on-lab-machine)
        - [Steps](#steps)
    - [Part 4 - Creating a Private Repository](#part-4---creating-a-private-repository)
    - [Part 5 - Basic Git Commands and Branching](#part-5---basic-git-commands-and-branching)
        - [Basic Git Workflow (add, commit, push)](#basic-git-workflow-add-commit-push)
        - [Creating and Submitting the Milestone Branch](#creating-and-submitting-the-milestone-branch)
    - [Part 6 - Submission Instructions](#part-6---submission-instructions)
- [**Assignment Overview**](#assignment-overview)
- [**Milestone Task Breakdown**](#milestone-task-breakdown)
    - [General Details Regarding the Milestone Format](#general-details-regarding-the-milestone-format)
    - [Milestone Submission](#milestone-submission)
    - [Final Submission](#final-submission)
- [**Implementation Details**](#implementation-details)
    - [Arc Card Data](#arc-card-data)
        - [Potential Issues](#potential-issues)
    - [Schedule File Structure](#schedule-file-structure)
        - [Generating a List File](#generating-a-list-file)
    - [Route Matching](#route-matching)
        - [Ambiguous Trips and Disambiguation Interface](#ambiguous-trips-and-disambiguation-interface)
        - [Missing Taps](#missing-taps)
    - [Corrupt Data](#corrupt-data)
    - [Time & ISO 8601](#time--iso-8601)
- [**Input And Output**](#input-and-output)
    - [Input](#input)
    - [Output](#output)
        - [Milestone Output](#milestone-output)
        - [Milestone Example I/O](#milestone-example-io)
        - [Final Submission Output](#final-submission-output)
        - [Final Submission Example I/O](#final-submission-example-io)
- [**Checking**](#checking)
    - [Generating Test Cases](#generating-test-cases)
- [**Marking Scheme**](#marking-scheme)

## Getting Started (Lab Setup)

Welcome to CMPUT201! We're happy to have you here! 
In this course we'll dive deep into standard C programming in Unix/Linux environment.

<!-- This first lab has a good amount of content to go through so please take your time. -->
<!-- Future labs will not require so much setup.  -->
It is very important that you read all steps, to ensure you know how to submit and test your code in this course. 
The tools we introduce to you here will be ones you will use in any programming-related career you may be interested in doing in the future. 
We hope that you can get comfortable using these tools throughout this year. 
For now though, this lab serves as a simple introduction.

<!-- If you need any help with the lab, please don't hesitate to email the TAs, attend *any* lab section (not just your own), or come to one of the TA office hours (Tuesdays and Thursdays, 11:00am - 1:30pm, usually @UCOMM 2-001, see Canvas for exceptions). -->

### Important Distinctions between Unix and Windows

Our course is aimed to teach you programming in Unix/Linux environment (some Unix based operating systems include MacOS, any Linux distribution, etc), not in Windows. 
We recognize that many students aren't ready to switch to Linux at this stage, so you can still use Windows machines for this course. 
Nevertheless, all the code you write __MUST be run on the lab machines__ (which are ucomm-2086-wXX.cs.ualberta.ca, where XX ranges from 00 to 33; for security reasons, you are not able to directly ssh into these machines, but through ohaton or UofA VPN, details see below and will be demoed in class).
__NEVER use the "play" button__ on VS Code (especially any extensions that claim to run C code for you), that's a fast-track to __getting a 0__ in the labs. 
There will be no exceptions for this, your code must run perfectly on the lab machines (which use Linux), since that's where all the marking will be done.

Notable differences for Windows include:
1. Using `\` instead of `/` for paths. Don't mix this up, since on Unix `\` is usually for escape characters like `\n`.
For example, the path `directory/file.txt` becomes `directory\file.txt` on Windows.
2. `~` also fails to expand to the home directory in many cases, so we use `$USERPROFILE` (a PowerShell exclusive), but in paths that sometimes requires the `$env:` prefix to expand, so `~/.ssh/config` on Unix is `$env:USERPROFILE\.ssh\config` on Windows. 
Note that whenever we ask to navigate to your home directory `$env:USERPROFILE`, it will most likely be in `C:\Users\[your username]`.

To save yourself any headaches, after following the set-up tutorial, make sure to SSH into the lab machines and do all your programming and compiling directly there.

### Part 1 - Setting up SSH
The SSH (Secure Shell) protocol is a tool to remotely connect to other computers (such as our lab machines) and it's indispensable in software development.
This allows for a standardized environment to develop and test your code, and avoids any cross-platform differences.
Even if you use a Unix operating system on your personal computer, you **must** ensure your code works as expected on the lab machines.

On MacOS and Linux, SSH is installed by default.
On any Windows 10 or 11 version after 2018, ssh *should* be installed by default as well.
You can check to make sure by opening up **PowerShell (not cmd)** and running `ssh -V`. 
If that produces an error, install [OpenSSH](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=gui#install-openssh-for-windows).

#### Generating an SSH Key
Start by creating an ssh key, which will allow you to connect to the lab machines without constantly re-typing your password.

Run the following in your terminal:

*If you already have an ssh key made, you do not need to make a new one and can skip this command.*

**Windows (PowerShell):**
```
ssh-keygen -t ed25519 -f $env:USERPROFILE\.ssh\id_ed25519
```
Hit enter twice for no passphrase.

**MacOS/Linux:**
```
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -P ""
```

#### Setting up the SSH Configuration

Now use a text editor to open your ssh `config` file, for example `code $env:USERPROFILE\.ssh\config` for VS Code on Windows.
Here you'll need to copy/paste the below text. 
Replace `<ccid>` with your ccid (the thing in front of @ualberta.ca for your email), and replace `<num>` with a number between `00` and `33` (two digits; we recommend `(student id) mod 34` to balance out among all students).

```sshconfig
Host lab
    Hostname ucomm-2086-w<num>.cs.ualberta.ca
    Port 22
    User <ccid>
    IdentityFile=~/.ssh/id_ed25519
    IdentitiesOnly=yes
    ProxyJump <ccid>@ohaton.cs.ualberta.ca
```

**In this and all following steps, make sure to replace `<ccid>` and `<num>` __including__ the characters `<` and `>`.**
For example, if your CCID is `johndoe` and your desired number is `00`, your config should look like:

```sshconfig
Host lab
    Hostname ucomm-2086-w00.cs.ualberta.ca
    Port 22
    User johndoe
    IdentityFile=~/.ssh/id_ed25519
    IdentitiesOnly=yes
    ProxyJump johndoe@ohaton.cs.ualberta.ca
```

Note that if you're experiencing issues connecting, try changing the `<num>` in this file. 
Your files are the same across all lab machines, so you can switch between them without any trouble. 
The above suggestion tries to even out the students using a machine to avoid potential issues.

Some text editors, such as Notepad on Windows, decide they know better than you and will call the saved text file `config.txt` instead of `config`.
If using the command `ssh lab` says `ssh: Could not resolve hostname lab: No such host is known.` or something simillar, this may be the cause.
To fix this, you can use the command:

**Windows:**
```
Rename-Item -Path "$env:USERPROFILE\.ssh\config.txt" -NewName "config"
```

**MacOS/Linux:**
```
mv ~/.ssh/config.txt ~/.ssh/config
```

#### Copying the SSH Key

Now we need to run the following command, where you once again need to replace `<ccid>` and `<num>`

**Windows (PowerShell):**
```
cd ~
cat .\.ssh\id_ed25519.pub | ssh -J <ccid>@ohaton.cs.ualberta.ca <ccid>@ucomm-2086-w<num>.cs.ualberta.ca "cat >> ~/.ssh/authorized_keys"
```
**MacOS/Linux:**
```bash
ssh-copy-id -o ProxyJump=<ccid>@ohaton.cs.ualberta.ca -i ~/.ssh/id_ed25519.pub <ccid>@ucomm-2086-w<num>.cs.ualberta.ca
```

**Continue for both Windows AND MacOS/Linux**

You might see something like the below. In this case type `yes` and hit enter. If it appears more than once, type `yes` each time. When you type `yes`, it may not appear as you type. It will still work however.

```
The authenticity of host 'ohaton.cs.ualberta.ca (129.128.243.70)' can't be established.
ED25519 key fingerprint is SHA256:SeHT9JqaLhpEpec6WXLYs9P1L3P75AWNav4e7b8GmpU.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Next it'll ask for your password. Type in the same password you use for Canvas, but notice that the cursor won't move while typing (it's a security measure). You may be prompted to type your password several times.

Some students may encounter an error "no such file or directory". 
IF this is the case, execute the following (replacing `<ccid>` and `<num>` again):
```
ssh -J <ccid>@ohaton.cs.ualberta.ca <ccid>@ucomm-2086-w<num>.cs.ualberta.ca "mkdir .ssh"
```
Then repeat the steps above starting from the "Copying the SSH Key" heading.

Now try `ssh lab`, which should log you in instantly, no password required! 
This is all you need for accessing lab machines from now on. 
<!-- If you're interested in learning more, consider [this tutorial](https://noway.moe/unix/ssh) by TAs in a previous year. -->

### Part 2 - Working on a Lab Machine through SSH

#### Connecting
In this part we'll learn how to connect and use the lab machines. 
These are provided by the university's department of Computing Science for our course and you all have access to them.

Start by opening up a terminal and run the following command:

```bash
ssh lab
```

Now you should be on the lab machine. 
If you did Part 1 correctly, you should not be prompted for a password.

#### The File System
In this part, we'll start using the Unix file system commands.
First, we're going to learn 3 commands, which we __heavily encourage__ you to search up to learn more about.

 - `ls`: This one lists the content of the current directory.
 - `cd`: Means "change directory"; this is how you move between directories.
 - `mkdir`: Means "make directory"; it creates a new directory.

Now follow these steps:

 1. Type `cd` to switch to your home directory (You can always type the command `pwd` to `p`rint your current `w`orking `d`irectory, at this point it should be `/cshome/<ccid>`).
 2. Make a directory for your CMPUT 201 work, using `mkdir CMPUT201`.
 3. Check to make sure you successfully made your directory with `ls`.
 4. Go into you CMPUT 201 directory with `cd CMPUT201`.
 5. List all the files in this directory (there won't be any).

**Important:** Any commands you run will execute in the current working directory. You will see this before the typing cursor. Ensure the file
you intend to work with is in the given folder with `ls` if you have issues.

#### Moving Files between Machines Using `scp`

Although we encourage you to write all code on the lab machines, you may find it easier to work with on your computer.
It is incredibly important to copy the code to the lab machines and run it there.
**There is 0 tolerance for code that runs perfectly on your computer but not on the lab machines. 
We will mark exclusively on the lab machines; so if it fails there, you will get a zero.**

To make things easy, in this part we'll setup a way to quickly copy over your code from your machine to the lab machines!

We've already setup the SSH connection, so let's try copying over a text file into the home directory of the lab machines. 
We will do this by using the `scp` (secure copy) command.
Start by creating a text file `test.txt` in any folder on your PC, then navigate to that folder in your terminal, and use the following command:

```bash
scp test.txt lab:~/mymovedfile.txt
```

Notice that `lab:` prepending the destination path? 
That indicates we should be copying to the host `lab`, which we previously set up.

If you want to copy over an entire folder, instead of just individual files, all we need to do is add the `-r` option to `scp` to make it "recursive". 
For example,

```bash
scp -r lab01 lab:~/CMPUT201
```

If you want to copy files inside the lab machine, you can use the `cp` command.

If you want to delete a file, you can use the `rm` command. Delete `mymovedfile.txt` with
```
rm mymovedfile.txt
```
And confirm with `y`.

### Part 3 - GitHub setup on Lab Machine

Now it's time to setup GitHub. Think of GitHub like cloud storage for code, but
it's exclusively controlled through `git`. As you may know, this is a vital tool for programmers used for version control.

Firstly, make a GitHub account at [https://github.com](https://github.com) if you don't already have one. 
<!-- Now join our GitHub Classroom by accepting lab 1 (if you're here, then you've probably done this already) through this ___.
Choose your CCID from the list. 
If your CCID does not show up, skip this step and contact Henry Tang (hktang@ualberta.ca) so he can add you (especially if you transfer in late). -->

You can connect to GitHub from your local machine, but we recommend that you use the lab machine to perform all your coding and commits as that environment is consistent for all students.

#### Steps

1. Click your profile icon in the top right on
    [https://github.com](https://github.com)
2. Click Settings
3. Click SSH and GPG Keys
4. Click New SSH Key. This should bring up an "Add new SSH Key" Menu
5. Set whatever "Title" is most memorable to you. For example "U of A Lab machine"
6. Set "Key Type" to Authentication
7. Open a terminal and ssh into the lab machine (`ssh lab`).
8. Create a ssh key for your GitHub account. (This will be a new key, not the one you created for sshing to the lab machine)
`ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -P ""`

9. The lab terminal, run `cat ~/.ssh/id_ed25519.pub`
10. Copy the output of that command. It should look something like `ssh-ed25519 jdi31aclAkaafnA81uweAnABSj ccid@ucomm-2086-wXX` (except the middle random characters portion will be longer and `ccid@ucomm-2086-wXX` will be your username and device name)
11. Then paste it into the "Key" section back in the "Add new SSH Key" Menu
12. Finally, click "Add SSH Key"
13. Open up `~/.ssh/config` in a text editor and paste the following at the bottom, then save and close the file:

```sshconfig
Host github.com
    Hostname github.com
    IdentityFile ~/.ssh/id_ed25519
```
14. Now in a terminal, run `ssh -T git@github.com` (type `yes` if prompted about the "authenticity of the host" as before). You should then get a message like the following, but with your username of course:
```
Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.
```
15. Now that SSH authentication is configured, you are ready to set up a private GitHub repository for your assignment code. Proceed to [Part 4 - Creating a Private Repository](#part-4---creating-a-private-repository) below to create your repository and link it to your local files.

### Part 4 - Creating a Private Repository

All assignment submissions must be hosted in a **Private** repository on GitHub to protect your code:

1. Go to [GitHub](https://github.com) and click the **+** icon in the top-right corner, then select **New repository**.
2. Set a **Repository name** (e.g., `cmput201-assignment01`).
3. Ensure the visibility is set to **Private**.
4. Leave "Initialize this repository with..." options unchecked if you already have a local directory with files.
5. Click **Create repository**.
6. Follow the instructions provided on GitHub to link your existing local directory to the remote repository:
   ```bash
   git remote add origin git@github.com:<your-username>/<your-repo-name>.git
   git branch -M main
   git push -u origin main
   ```

---

### Part 5 - Basic Git Commands and Branching

`git` provides a way to incrementally track changes in your code and publish them to a remote repository. In this section, you will learn the fundamental `git` commands and how to create a submission branch for your milestone.

#### Basic Git Workflow (`add`, `commit`, `push`)

When working on your code, you will frequently check your changes, stage them, and record commits:

1. **Check Status:**
   Run `git status` to view modified, staged, or untracked files in your directory:
   ```bash
   git status
   ```

2. **Stage Changes (`git add`):**
   Add specific files to the staging area:
   ```bash
   git add src/assg.c list_file.txt
   ```
   Or stage all changes in the current directory:
   ```bash
   git add .
   ```

3. **Commit Changes (`git commit`):**
   Record your staged changes with a meaningful message:
   ```bash
   git commit -m "Implement list file parsing for milestone"
   ```

4. **Push Changes (`git push`):**
   Upload your local commits to your remote GitHub repository:
   ```bash
   git push
   ```

> [!TIP]
> Commit and push your work frequently! Committing often makes it easier to trace your progress and revert unwanted changes if needed.

#### Creating and Submitting the Milestone Branch

For the milestone submission, you are required to submit your code on a dedicated branch named `milestone-submission`. This allows course staff to grade your milestone snapshot while you continue working on `main` for the final submission.

1. **Create and Switch to the Branch:**
   Create the `milestone-submission` branch and switch to it:
   ```bash
   git checkout -b milestone-submission
   ```
   *(Alternatively, using newer Git versions: `git switch -c milestone-submission`)*

2. **Push the Branch to GitHub:**
   Push your milestone branch to your remote GitHub repository:
   ```bash
   git push -u origin milestone-submission
   ```

3. **Switch Back to `main` to Continue Working:**
   After pushing your milestone branch, switch back to the `main` branch to continue working on the final submission tasks:
   ```bash
   git checkout main
   ```

---

### Part 6 - Submission Instructions

Once you have pushed your `milestone-submission` branch (or your `main` branch for the final submission), complete your submission by filling out the Google Form below:

> [!IMPORTANT]
> Submit your repository details using the official submission form:
> [Google Form Submission Link]()

Make sure your repository link is correct and that your `milestone-submission` branch has been pushed prior to the deadline.



Congratulations! You have now completed all the setup necessary to begin working on the Assignment. Proceed by reviewing the Assignment Overview below.

## Assignment Overview

In this assignment, you will build a data processing pipeline in C. Your program will read a rider's tap history and a set of bus route files, then output a txt summary of their trips to a file named `output.txt`. You will do this by matching each entry exit pair in a user's arc data to a bus route that runs in Simplemonton.

---

This description consists of three sections: [Milestone Task Breakdown](#milestone-task-breakdown), [Implementation Details](#implementation-details) and [input/output specifications and examples](#input-and-output). The purpose of each section is described below:

1. [**Milestone Task Breakdown**](#milestone-task-breakdown): For submission timeline purposes, this assignment is broken down into a Milestone Submission and a Final Submission. You should have a working part of the assignment done the  milestone. This is for you to properly test your program at different stages. The milestone section in this description is to provide you with the specifics regarding which tasks should be completed by the milestone's deadline.

2. [**Implementation Details**](#implementation-details): Here we describe the way the program functions conceptually, as well as implementation requirements. This section does not necessarily describe each task in the order that they should be implemented in (that is what the milestone section is for). **We recommend to make sure you understand how the overall program functions before starting with any implementation.**

3. [**Input and Output Specifications and Examples**](#input-and-output): We will provide you with the specifics regarding the input format and what's expected from you in terms of output for the milestone and final submission. Finally, for the milestone and final submission, example I/O is provided as well.

---

The suggested workflow is:
1. Find the stage of the assignment (either the Milestone or Final Submission) you plan to work on in the [milestone breakdown section](#milestone-task-breakdown).
2. Find the task you plan to work on.
3. Complete the task by referring to the implementation details section corresponding to the task.
4. Do this for each task in the milestone, testing your code as you go along.
5. Once you complete every task, you can check your progress by looking at the [I/O examples](#input-and-output), and by running [the appropriate check script](#checking).

Fair warning: this assignment is long and challenging. **There is a reason you get a third of the semester to do it.** The milestone is there to encourage people to get started early. If you are struggling, make sure to attend lab sections and office hours to ask for help. Good luck!


## Milestone Task Breakdown

This section outlines what you should be working on and should complete for each milestone. For implementation details and explanations, refer to the [implementation section](#implementation-details).

This section is designed as follows: each milestone section below will contain what needs to be completed by the due date of that milestone. Once you know what you have to work on next, refer to the [implementation section](#implementation-details) of that respective task/concept, there you will find the explanations for the concepts, as well as the implementation details.

### General Details Regarding the Milestone Format

- You will be provided with a check script for each milestone and the final submission for you to verify your progress ([more details on check](#checking)).
- The Milestone Submission and Final Submission are each graded out of $10$ points, and weigh **[????]** of your final grade ([more details on the marking scheme](#marking-scheme)).
- While there are $2$ stages of this assignment, it should be **one overall program**.
- The Milestone has a three week period available to be completed. There is one week between the due date of the Milestone Submission and the due date of the Final Submission.

### Milestone Submission

For the milestone, your program is not required to process the tap history file or generate `output.txt`. Instead, its sole purpose is to verify that it can successfully read the list file (`argv[1]`), open each corresponding schedule file, and extract its metadata. For this stage, your program should only accept **one** command-line argument.

1. Generate the list file used to read all schedules files. See [Generating a List File](#generating-a-list-file) for the required format. Save this file as `list_file.txt`
2. Create `assg.c`. This is where the main function will be and the file your program is compiled from.
3. Implement file input and processing using your generated list file, read the required information from each schedule file. See [Schedule File Structure](#schedule-file-structure).
4. Output to `stdout` according to the [Milestone output specification](#milestone-output).

**Mandatory files for Milestone Submission:** `src/assg.c`, `list_file.txt`

See: [Milestone Submission Example I/O](#milestone-example-io)

### Final Submission

The final submission requires a complete processing pipeline. Your program will transition to accepting **two** command-line arguments: the list file and the tap history file.

1. Implement the journey reconstruction logic. Your program must process the tap history file, matching entry and exit records to reconstruct trips.
2. Handle [ambiguous trips](#ambiguous-trips-and-disambiguation-interface) by prompting the user on `stdout`.
3. Implement the [guessing algorithm](#missing-taps) for missing taps.
4. Output the reconstructed journey to `output.txt` according to the [Final Submission output specification](#final-submission-output).

**Mandatory files for Final Submission:** `src/assg.c`, `list_file.txt`

See: [Final Submission Example I/O](#final-submission-example-io)

## Implementation Details

This section explains the implementation concepts needed to complete the assignment. We will of course not give you all the specifics since we want you to implement the grand majority of the program yourself.

Use this as a guide for the concepts needed for you to complete the assignment. **Do not use this section for order of implementation**, for that please refer to the Milestone breakdown section before this one. Once familiar with the concepts and process, your task is then to translate that into C code as specified.

### Arc Card Data

Records are provided in **reverse chronological order**. This is a critical detail: the most recent events appear at the top of the file, meaning you will encounter an exit record *before* you see its corresponding entry tap. In other words, an "earlier" line in the file is actually a *later* event in real time.

Each record contains:
- `Date`: `MM-DD-YYYY` (e.g., `05-01-2026`)
- `Time`: `HH:MM PM/AM` (e.g., `01:07 PM`)
- `Type`: A single character representing the transaction type:
    - `E`: Entry tap
    - `X`: Exit tap
    - `M`: Missing tap fare
- `Location`: Integer stop ID (This may be blank for a Missing Tap Fare).


#### Potential issues

Sometimes, a User will forget to record an exit tap. Within the data, this will look like: `12-13-2024,05:38 PM,M,`. Since there is no exit tap, you will have to implement an algorithm that will 'guess' the most likely exit stop based on the user's commute history. More details given in the [Missing Taps section](#missing-taps).

Some lines will have corrupt data, such as invalid stop IDs or incomplete or missing fields. You will have to handle these errors and notify the user how their data is corrupted. See the [output specifications](#output).

Finally, some buses run along the same stretches of the city. Based on tap data, you will prompt the user with all possible routes for a given set of an entry/exit taps, then produce the selected route in the final output. See the [Ambiguous Trips section](#ambiguous-trips-and-disambiguation-interface) for more details.

### Schedule File Structure

In order to match trips, you'll have to open all the schedule files and process the data within them. To do this your program will accept two command-line arguments:
1. `argv[1]`: A text file containing a list of all the route schedule filenames.
2. `argv[2]`: The input file containing the tap history (e.g., `FS_Testcases/1-1-input.txt`).

Every schedule file in `simplified_schedules/` follows a standardized structure to make parsing straightforward.

```
<int> <route_name>, <int> Stops
stop_id,stop_name
```

The first line contains the route number, the route name (formatted as a single string with no spaces), and the total number of stops. While you must read this header to access the stops, the route name itself is not used in any output. Every following line represents a stop on that route, containing the stop ID and the stop name, separated by a comma.

**Example:**

```
101 Abbottsfield, 32 Stops
1407,Stadium_TC_on_111_Avenue
1081,84_Street_&_110_Avenue
1394,84_Street_&_Jasper_Avenue
1244,82_Street_&_Jasper_Avenue
...
```

#### Generating a List File

To create the list file, you must list the filenames and prepend the directory path so your C code can find them. The final result (`list_file.txt`) should look like:
```
simplified_schedules/route_101_EB.txt
simplified_schedules/route_101_WB.txt
simplified_schedules/route_102_EB.txt
simplified_schedules/route_102_WB.txt
...
```
> [!TIP]
> You can generate this file in whichever way you'd like using the tools covered in class. Some helpful commands include `ls` for listing files, `wc -l` for counting them, and using search-and-replace tools like `sed` or Vim substitutions (`:%s/^/prefix/g`).

Once you have generated this list file, you can pass it to your program as the first argument. Your C code can then open this list file and use the full paths within it to access the individual route schedules.

### Route Matching

A trip belongs to a route if **both** the entry and exit stop IDs appear in that route's schedule file in `simplified_schedules/`. 

To reconstruct a valid trip, your program must search the available schedules to find the route(s) containing both the entry and exit stops. If an entry and exit stop pair is found in multiple routes, your program must handle the overlap (see the [Ambiguous Trips](#ambiguous-trips-and-disambiguation-interface) section). Once the correct route is identified, the trip details are formatted and written to the output file.

#### Ambiguous Trips and Disambiguation Interface

Sometimes, an entry and exit stop pair can belong to multiple bus routes. In such cases, your program must interactively prompt the user to select the correct route. 

The prompt should be written to `stdout`, list all possible routes with a number, and the user should input the number corresponding to their choice via `stdin`.

> [!TIP]
> To size your arrays safely for the disambiguation list, note that the maximum number of schedules any single stop belongs to in the provided dataset is **14**. 

Example prompt on `stdout`:
```
Ambiguous trip detected:
Entry: 2853 (101_Street_&_82_Avenue)
Exit: 2689 (109_Street_&_82_Avenue)
Possible routes:
1. 4 W
2. 8 W
Select route (1-2): 
```

Once the user makes a selection, your program should use that route for the trip summary in the final `output.txt` file.

#### Missing Taps

When riding the STA, sometimes tapping off is hard! It is easy to forget to log your trip. Luckily, you have a solution for commuters looking to get data for their travels. A fellow engineer at your office has devised an algorithm for best guessing missing travels. The way it works is to find the most frequent exit stop given an entry stop *and* a time. If a Missing Tap Fare entry is found, you must look at the corresponding entry tap. The way you must guess the most likely exit is to use the user's commute history. For example, if every morning they get on at `135_Street_&_107_Avenue`, and always tap off at `114_Street_&_89_Avenue`, then a Missing Tap Entry can be guessed to have actually been an exit at that time.

Essentially, you will make hourly 'buckets' where each bucket corresponds to an hour of the day (e.g., 7:00 AM to 7:59 AM). If a user taps on at a specific stop within a specific hour, in the case of a missing exit tap, you must guess the most common exit stop that happens for entry stops made in that hour. This is because during different times of the day, a user may make different travels based off the same stop.

The algorithm guesses missing tap-off stops using historical commute data structured into hourly buckets:

1. For every arc card data entry of type `E`, there should be a corresponding 'X' or 'M' record.
2. Historical trips are organized into groups based on where they started (the stop ID of the `E` tap) and the hour of the day. These "buckets" encapsulate the entire hour from :00 to :59 (for example, any trip starting between 7:00 AM and 7:59 AM is grouped together).
3. Within the matching bucket, the algorithm counts the frequency of each exit stop and selects the most frequent one as the guess.
4. **Guessed Flag:** Any trip that is reconstructed using this guessing algorithm must have the tag `,Guessed` appended to its line in the final `output.txt`.
5. **Processing Order:** As noted in [Arc Card Data](#arc-card-data), the file is in reverse chronological order. You should **always** process data in chonological order. 

### Corrupt Data

Your program will be required to detect errors in the formatting of input files. This will be useful when providing your own testcases. In the case that there the entry lines do not follow the format specified in [Arc Card Data](#arc-card-data), you will report through `stdout` as such. In the case that a stop ID does not appear in the schedules provided to the program, your program should report through `stdout` that there appears an invalid stop ID.

### Time & ISO 8601

Standardize all timestamps to **ISO 8601** (`YYYY-MM-DDTHH:MM:SS`) in the final output. You must convert 12-hour input (e.g., `01:16 PM`) to 24-hour format and calculate trip durations formatted as `H:MM:SS`.

**Example:**
- **Input:** `05-01-2026,01:16 PM`
- **Output:** `2026-05-01T13:16:00`


## Input And Output

### Input

The input is provided via command-line arguments and a structured tap history file.

1.  **Command-Line Arguments:**
    The program's arguments depend on the submission stage:
    *   **Milestone**: `./arc_analyzer <list file path>`
    *   **Final Submission**: `./arc_analyzer <list file path> <input file path>`
    
    *   `argv[1]`: Path to the file containing the list of route schedules (see [Generating a List File](#generating-a-list-file)).
    *   `argv[2]`: Path to the input file containing tap history (e.g., `FS_Testcases/1-1-input.txt`). **Note:** This argument is not used for the milestone.

2.  **Tap History File:**
    The input file follows this structure:
    ```
    <number of records n (int)>
    <record 1>
    ...
    <record n>
    ```
    Each record follows the `Date,Time,Type,Location` format described in [Arc Card Data](#arc-card-data). Remember that records are provided in **reverse chronological order**.

3.  **Interactive Input:**
    During [disambiguation](#ambiguous-trips-and-disambiguation-interface), the program reads the user's selection from `stdin`.

### Output

The program processes the tap records to reconstruct a journey, writing the final summary to `output.txt`.

1.  **Journey Summary (`output.txt`):**
    Each line in the output file represents a single trip, sorted in **chronological order**. The fields are:
    `<Route>,<Entry Stop>,<Exit Stop>,<Entry Time>,<Exit Time>,<Duration>[,Guessed]`

    *   **Route**: Route number and direction character (e.g., `101 E`).
    *   **Stop Names**: Full names found in the [schedule files](#schedule-file-structure).
    *   **Timestamps**: Combined ISO 8601 format (see [Time & ISO 8601](#time--iso-8601)).
    *   **Duration**: Formatted as `H:MM:SS`.
    *   **Guessed**: This tag is appended only if the exit was [guessed](#missing-taps).

2.  **Interaction and Errors:**
    *   [Disambiguation prompts](#ambiguous-trips-and-disambiguation-interface) are printed to `stdout`.
    *   If data is [corrupt](#potential-issues) or invalid (e.g., `Invalid stop ID`), the program outputs an erro
    r message and handles it as specified by the milestone.

---

#### Milestone Output

Your program must output to `stdout`.

First, print a line stating the total number of schedule files being processed:
    `Processing <count> schedule files...`
  
For each schedule file, a single line summarizing its metadata in the following format:
    `schedule #<count> is route <id> it has <num> stops and is in the <D> direction`

Where:
*   `<count>` is the 1-based index of the file being processed.
*   `<id>` is the full route ID (e.g., `101`, `110X`). Note that for express routes, the trailing `X` from the filename must be included.
*   `<num>` is the integer number of stops on that route.
*   `<D>` is the single character direction extracted from the filename (`E`, `W`, `N`, or `S`).

#### Milestone Example I/O

##### Example

Example execution: `./a.out list_file.txt`

Output (`stdout`):

```
Processing 221 schedule files...
schedule #1 is route 101 it has 32 stops and is in the E direction
schedule #2 is route 101 it has 34 stops and is in the W direction
schedule #3 is route 102 it has 47 stops and is in the E direction
schedule #4 is route 102 it has 53 stops and is in the W direction
schedule #5 is route 103 it has 63 stops and is in the E direction
schedule #6 is route 103 it has 64 stops and is in the W direction
...
schedule #218 is route 930X it has 30 stops and is in the S direction
schedule #219 is route 930X it has 27 stops and is in the W direction
schedule #220 is route 9 it has 51 stops and is in the E direction
schedule #221 is route 9 it has 52 stops and is in the W direction
```

#### Final Submission Output

The final submission requires a complete processing pipeline. Your program will transition to accepting **two** command-line arguments: the list file and the tap history file.

1.  **Journey Summary (`output.txt`):**
    You must reconstruct the user's journey from the reverse-chronological tap records. The final output must be written to `output.txt`, with trips sorted in **chronological order** (oldest trip first). Each line must follow this format:
    `<Route>,<Entry Stop>,<Exit Stop>,<Entry Time>,<Exit Time>,<Duration>[,Guessed]`

    *   **Route**: The route ID and direction (e.g., `101 E`).
    *   **Stops**: The full names of the entry and exit stops as found in the schedule files. Underscores should be preserved.
    *   **Times**: Both entry and exit times must be in ISO 8601 format (`YYYY-MM-DDTHH:MM:SS`).
    *   **Duration**: The total travel time formatted as `H:MM:SS`.
    *   **Guessed**: If the exit stop was determined via the [guessing algorithm](#missing-taps), you must append `,Guessed` to the line.

    **Note:** There should be no header line in `output.txt`.

2.  **Interaction (`stdout`):**
    If a trip is [ambiguous](#ambiguous-trips-and-disambiguation-interface), you must prompt the user on `stdout` and wait for their input on `stdin`. Error messages (e.g., for corrupt data or invalid stop IDs) should also be printed to `stdout`.

#### Final Submission Example I/O

##### Example 1

Input:

```
4
05-01-2026,01:16 PM,X,2001
05-01-2026,01:07 PM,E,2231
04-30-2026,01:18 AM,X,5210
04-30-2026,12:58 AM,E,1328
```

Output (`output.txt`):

```
5 W,96_Street_&_Jasper_Avenue,Westmount_Transit_Centre,2026-04-30T00:58:00,2026-04-30T01:18:00,0:20:00
4 W,71_Street_&_90_Avenue,University_Transit_Centre,2026-05-01T13:07:00,2026-05-01T13:16:00,0:09:00
```

##### Example 2

Input:

```
4
05-02-2026,03:20 PM,X,1336
05-02-2026,02:56 PM,E,5210
05-02-2026,03:06 PM,X,2002
05-02-2026,02:32 PM,E,5216
```

Output (`output.txt`):

```
4 E,West_Edmonton_Mall_Transit_Centre,University_Transit_Centre,2026-05-02T14:32:00,2026-05-02T15:06:00,0:34:00
5 E,Westmount_Transit_Centre,101_Street_&_Jasper_Avenue,2026-05-02T14:56:00,2026-05-02T15:20:00,0:24:00
```

##### Example 3 (Ambiguous Trip)

Input File (`argv[2]`):

```
2
05-05-2026,08:15 AM,X,2689
05-05-2026,08:10 AM,E,2853
```

Standard Input (`stdin`):

```
2
```

Output (`stdout`):

```
Ambiguous trip detected:
Entry: 2853 (101_Street_&_82_Avenue)
Exit: 2689 (109_Street_&_82_Avenue)
Possible routes:
1. 4 W
2. 8 W
Select route (1-2): 
```

Output (`output.txt`):

```
8 W,101_Street_&_82_Avenue,109_Street_&_82_Avenue,2026-05-05T08:10:00,2026-05-05T08:15:00,0:05:00
```

##### Example 4 (Missing Tap Guessing)

Input:

```
8
05-04-2026,12:45 PM,M,
05-04-2026,12:20 PM,E,1328
05-03-2026,12:35 PM,X,5210
05-03-2026,12:15 PM,E,1328
05-02-2026,12:40 PM,X,5210
05-02-2026,12:20 PM,E,1328
05-01-2026,12:30 PM,X,5210
05-01-2026,12:10 PM,E,1328
```

Output (`output.txt`):

```
5 W,96_Street_&_Jasper_Avenue,Westmount_Transit_Centre,2026-05-01T12:10:00,2026-05-01T12:30:00,0:20:00
5 W,96_Street_&_Jasper_Avenue,Westmount_Transit_Centre,2026-05-02T12:20:00,2026-05-02T12:40:00,0:20:00
5 W,96_Street_&_Jasper_Avenue,Westmount_Transit_Centre,2026-05-03T12:15:00,2026-05-03T12:35:00,0:20:00
5 W,96_Street_&_Jasper_Avenue,Westmount_Transit_Centre,2026-05-04T12:20:00,2026-05-04T12:45:00,0:25:00,Guessed
```

##### Example 5 (Incorrect Formatting)

Input:

```
2
05-01-2026,01:16 PM,X,2001
malformed,line,here
```

Output (`stdout`):

```
Invalid data format
```

##### Example 6 (Invalid Stop ID)

Input:

```
2
05-01-2026,01:16 PM,X,999999
05-01-2026,01:07 PM,E,1328
```

Output (`stdout`):

```
Invalid stop ID
```


## Checking

### Generating Test Cases

In this assignment, you are highly encouraged to develop your own set of test cases. Review closely the format of input and output. The following instructions will prove helpful when generating test cases.

1. Confirm that all stop IDs provided in an input file appear in a schedule file, and thus correspond to a real stop.
2. Confirm that any exit/entry tap pair contains a stop id pair that both appear in one or more bus trips. That is, make sure arc data reports trips that are actually possible given the schedule data provided.
3. Note the implementation of the [Missing Taps](#missing-taps) algorithm makes a distinction on *the hour of the day* which a entry tap is on when predicting the most likely exit tap. When generating the correct output make sure that the `Guessed` trips follow the logic that is specified in the implementation.
4. The reccomended process for generating an arc card history is as follows:
    - Choose a bus route on which a trip will occur. Decide on entry and exit points. Note: choosing shorter trips have a higher chance of being an ambiguous trip.
    - Find the Stop IDs that correspond to these entry and exit points. Add these to the input and create the corresponding output row at the same time.
    - Repeat the process for any trip which will have an entry and exit point.
    - When adding in trips in which there is a Missing Tap, make sure that there is enough historical data at containing that trip's starting point and time pair for your program to accurately predict the exit stop.
    - Create a `stdin` file which disambiguates trips to match the intended route as provided in the output.

## Marking Scheme
