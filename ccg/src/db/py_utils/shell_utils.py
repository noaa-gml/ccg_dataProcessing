#!/usr/bin/env python3
"""Wrappers for running various shell commands in python"""
import os
import sys
import subprocess


def run_shell_cmd(cmd,printOutput=True,quitOnError=True,stdin=None):
    """Run passed command and handle errors"""
    #cmd is the primary command to run with arguments (e.g. ls -l)
    #stdin, if passed is piped into cmd.  This statement must have output (e.g. echo "asdf")
    #example:
    #   import shell_utils as shell
    #   #to print directory listing
    #   shell.run_shell_cmd("ls -l")

    #   #to pipe ls through grep for svn files
    #   shell.run_shell_cmd("grep svn",stdin="ls -l")

    #This returns stdout

    try:
        if stdin : cmd=stdin+"|"+cmd
        p=subprocess.run(cmd,text=True,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        if printOutput : print(p.stdout)
        return p.stdout

    except subprocess.CalledProcessError as e:
        print("Error: ",e.output)
        if quitOnError : sys.exit()

    return None


def file_nlines(fileName):
    """return number of lines in file"""
    #pass full/relative path to file.  This returns number of lines as an integer
    #Quits on error (ie if file doesn't exist)
    #ex:
    #    n=shell.file_nlines("t.html")
    cmd="wc -l <"+fileName
    o=run_shell_cmd(cmd,printOutput=False)
    try:
        o=int(o)
    except:
        print(o)
        sys.exit()
    return o

def run_parellel_cmds(cmd,seqMax=None,inputFile=None,stdin=None, maxConcurrent=None, outputFile=None):
    """Run cmd in parallel for each item in stdin/file"""
    #seqMax, inputFile or stdin must be passed.  Requires installation of gnu parallel command.

    #This runs cmd through paraellel to run maxConcurrent processes, one for each line of input
    #if seqMax passed this generates a list of indexes 0 to seqMax and passes each as (last) parameter to cmd
    #if inputFile passed, this passes each line of file to cmd as last parameter
    #if stdin passed, you can use what ever arbitrary input list you want (e.g. seq 0 2 10 for stepped sequence)
    #if maxConcurrent passed, only that number of concurrent processes will be run at a time.
    #   Defaults to number of available processors.
    #if outputFile passed, all processes append their output to file (this could be enhanced...).
    #   Default is stdout
    #ex:
    #   #run program t.bash and pass in each line of file ./input as a parameter ($1), write to out.txt
    #   shell.run_parellel_cmds("./t.bash",inputFile='./input', outputFile='out.txt')

    #   #similar but pass 10 as a parameter 1 ($1) and generate a sequence 0 to 50 for parameter 2($2)
    #   #   and use max 10 concurrent processes
    #   shell.run_parellel_cmds("./t.bash 10",seqMax=50, outputFile='out.txt',maxConcurrent=10)

    #   #similar but use custom input, output to screen
    #   shell.run_parellel_cmds("./t.bash",stdin='seq 0 2 10', outputFile='out.txt')

    j="-j "+str(maxConcurrent)+' ' if maxConcurrent else ''
    c='|parallel '+j+'"'+cmd+' {}"'

    if stdin : c=stdin+c #just pass through directly
    elif seqMax : c="seq 0 "+str(seqMax)+c #generate a sequence
    elif inputFile : c="cat "+inputFile+c # cat file to run on each line.
    else :
        print("Error; seqMax, inputFile or stdin must be passed.")
        sys.exit()
    if outputFile : c=c+">"+outputFile
    printOutput=False if outputFile else True

    run_shell_cmd(c,printOutput=printOutput)

