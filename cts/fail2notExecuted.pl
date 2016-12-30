#!/usr/bin/perl -w
use strict;
use 5.010;

################################################################################
# fail2notExecuted.pl [path of testResult.xml]

# 原始文件将被重命名为 testResut.xml.bak
# 如不需备份可修改本文件: $^I = ""
################################################################################


my ($notExecuted, $fail) = (0, 0);
my $head = qr/^(\s*<Summary.*? failed=")(\d+)(?{$notExecuted = $^N})(" notExecuted=")(\d+)(?{$notExecuted += $^N})"/;

# undef $/;
$^I = ".bak";

unless (@ARGV) {
  @ARGV = -f "testResult.xml" ? "testResult.xml"
    : -f "xtsTestResult.xml" ? "xtsTestResult.xml"
    : -f "test_result.xml" ? "test_result.xml"
    : ();
  say $ARGV[0];
  die "no such files, please check!!!" unless @ARGV;
}


my ($tag, $del);
my ($phone, $imsi);
while(<>) {
    if(!$phone) {
        if (/<PhoneSubInfo subscriberId="([^"]+)"/) {
            $phone = $1;
            if ($phone =~ /(\+?\d++)(?!.*\d)/) {
                $phone = $1;
                s/(^\s*<PhoneSubInfo subscriberId=")([^"]*)(".*)$/$1$phone$3/;
            }
        }
    }
    if(!$imsi) {
        if (/^\s*<BuildInfo.*imsi="([^"]+)"\s*\/>/) {
            $imsi = $1;
            if ($imsi =~ /(\d++)(?!.*\d)/) {
                $imsi = $1;
                s/(^\s*<BuildInfo.*imsi=")([^"]*)(".*)$/$1$imsi$3/;
            }
        }
    }
    if(!$tag){
        $tag = 1 if s{$head}{$1$fail$3$notExecuted"}m;
    } else {
        if (/<Fail(?:edScene|ure)/) {
            $del = 1;
            next ;
        }
        if (/<\/Fail(?:edScene|ure)>/) {
            $del = 0 ;
            next;
        }
        next if $del ;
        s/result="fail"/result="notExecuted"/;
    }
    print;
}
