#!/usr/bin/perl

$LOGFILE = 'switch.log';
$INDEX_FILE = 'left.index';

################# FUNCTIONS ######################

sub write_index {
        open LFT, ">", $INDEX_FILE or die("Could not open log file.");
        print LFT $_[0];
        close(LFT);
        # Open the index file and write the first argument of the function,
        # which should be the index in the log file were we are, or the end of the log file.
}

sub read_index {
        open LFT, "<", $INDEX_FILE or die("Could not open index file.");
        $TELL = (<LFT>);
        if (!defined $TELL) {
                $TELL=1;
        }
        # Open the index file and read the index in the log file from where
        # we should start reading.
}

sub check_files {
        unless (-e $LOGFILE) {
                print("Log file does not exist, nothing to do\n");
                exit(1);
        }

        unless (-e $INDEX_FILE) {
                open LFT, ">", $INDEX_FILE or die("Could not create index file.");
                close(LFT);
                # If the index file doesn't exit is probably the first time we run this script.
                # Or someone deleted the index file.
        }
}

############### END FUNCTIONS ####################

check_files();  # Check the existence of the log file.
read_index();   # Read the index, where we left last time, from our log file.

open LOG, "<", $LOGFILE or die("Could not open log file.");

$ret_value = seek(LOG, $TELL-1, 0);
        if ($ret_value != 1) {
                die("Error");
        }
        # should never happend as linux/unix lets us go even beyond eof of a file,
        # but something else may have happend so is best to check the function's return value.

if (eof(LOG)) {
        seek(LOG, 0, 0);
        #Log was probably rotated, we are lost, go to beginning.
}

$str_one = "\%AUTHMGR-7-NOMOREMETHODS\: Exhausted all authentication methods for client";
$str_two = "on Interface";
$str_three = "AuditSessionID";
foreach $line (<LOG>) {
        #print($line);
                if ($line =~ m/(^\w{3}) (\d+) (\d+:\d+:\d+) ((\d{1,3}\.){3}\d{1,3}) (\d+\:) (\w{3}) (\d+) (\d+:\d+:\d+)\: ($str_one) \(((([0-9A-Fa-f]){4}\.){2}([0-9A-Fa-f]){4})\) ($str_two) (([GF][ia])((\d\/){1,2}\d{1,2})) ($str_three) \w*$/) {
                print($line);
                print("$1 $2 $3 $4 Offending MAC Address $11 on interface $16\n");
        }
}
$TELL = tell(LOG);

close(LOG);

write_index($TELL);

# REGEXP
# \w{3} char 3 times, -- Month Ex: Sep
# \d+ digit 1 or more times -- Day of month
# \d+:\d+:\d+ -- time 07:33:07
# This is the date on the SERVER

# \d{1,3} digit one,two or three times
# \. is a dot
# last two lines three times
# again \d{1,3} digit one,two or three times
# The ip address.

# \d+ digit 1 or more times, folowed by a colon
# This is the log line.

# \w{3} char 3 times, -- Month Ex: Sep
# \d+ digit 1 or more times -- Day of month
# \d+:\d+:\d+ -- time 07:33:07
# This is the date on the SWITCH

# ([0-9A-Fa-f]){4}\. --- match part of mac xxxx.
# All this two times, and one more time without the dot.
# The mac address

# [GF][ia] match Gi/Fa or Ga/Fi
# (\d\/){1,2}\d{1,2}) - 4/0/20 or 5/2
# The interface
