#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

my ($dir, $audio_mk) = @ARGV;
$dir.= "/" unless $dir =~ m!/$!;
opendir ALLAUDIO, $dir or die "open $dir error!!";
open MAKEFILE, ">>", $audio_mk or die "open $audio_mk error!!";
my ($a_tpath, $n_tpath, $r_tpath, $e_tpath) = (
    'system/media/audio/alarms/',
    'system/media/audio/notifications/',
    'system/media/audio/ringtones/',
    'system/media/audio/ui/'
    );
my $count;
my %ui;
open DEF_AU, "./AllAudio.mk" or die "open AllAudio.mk err";
while (<DEF_AU>) {
    chomp;
    if ($_ =~ m#effects/[^:]+:system/media/audio/ui/([a-zA-z.]+)[ \\]+$#) {
        say $1;
        $ui{$1} = $_;
    }
}
close DEF_AU;
while (my $subdir = readdir ALLAUDIO) {
    if (-d $subdir && $subdir =~ /alarms/) {
        opendir ALARM, $dir.$subdir or die "open alarm error!";
        $count = 0;
        while (readdir ALARM) {
            unless (-d $_) {
                $count++;
                print MAKEFILE '    $(LOCAL_PATH)/'."$dir"."alarms/".$_.":$a_tpath".$_." \\\n";
            }
        }
        close ALARM;
        say "subdir:$subdir count: $count";
    } elsif (-d $subdir && $subdir =~ /notifications/) {
        opendir NOTIFICATION, $dir.$subdir or die "open alarm error!";
        $count = 0;
        while ((readdir NOTIFICATION)) {
            unless (-d $_) {
                print MAKEFILE '    $(LOCAL_PATH)/'."$dir"."notifications/".$_.":$n_tpath".$_." \\\n";
                $count++;
            }
        }
        close NOTIFICATION;
        say "subdir:$subdir count: $count";
    } elsif (-d $subdir && $subdir =~ /ringtones/) {
        opendir RINGTONE, $dir.$subdir or die "open alarm error!";
        $count = 0;
        while ((readdir RINGTONE)) {
            unless (-d $_) {
                print MAKEFILE '    $(LOCAL_PATH)/'."$dir"."ringtones/".$_.":$r_tpath".$_." \\\n";
                $count++;
            }
        }
        close RINGTONE;
        say "subdir:$subdir count: $count";
    } elsif (-d $subdir && $subdir =~ /effects/) {
        opendir UI, $dir.$subdir or die "open alarm error!";
        $count = 0;
        while ((readdir UI)) {
            if (!-d $_ && exists $ui{$_}) {
                print MAKEFILE '    $(LOCAL_PATH)/'."$dir"."effects/".$_.":$e_tpath".$_." \\\n";
                delete $ui{$_};
            }
        }
        close RINGTONE;
        for my $key (keys %ui) {
            print MAKEFILE $ui{$key}."\n";
        }
    }
}
