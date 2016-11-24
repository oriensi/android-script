#!/usr/bin/perl -w
use strict;
use 5.010;

my $prefix = "1064";
my $value = "090-999";
# say for reverse (1 .. 1);
# exit;
my $not_null_value = $value;
while ($value =~ m/(\d+)-(\d+)/) {
  my $temp;
  my @temp_array = ($1 .. $2);
  my @num_array;
  while (scalar @temp_array) {
    my $len = length($temp_array[-1] - $temp_array[0] + 1) - 1;
    if ($len >= 1 && rindex($temp_array[0], '0') > -1) {
      for my $i (reverse (1 .. $len)) {
        if(rindex ($temp_array[0], '0' x $i) > -1) {
          my $push = substr($temp_array[0], 0, 0 - $i);
          say '[0]:' . $temp_array[0] . "  push: " . $push;
          push @num_array, $push;
#          my $first = $temp_array[0];
          @temp_array = grep {$_ > $temp_array[0] + 10 ** $i - 1} @temp_array;
          last;
        }
      }

    # if ($temp_array[0] % 100 == 0 && $temp_array[0] + 99 <= $temp_array[-1]) {
    #   my $shift_temp = $temp_array[0];
    #   @temp_array = grep {$_ > $shift_temp + 99} @temp_array;
    #   chop $shift_temp;
    #   chop $shift_temp;
    #   push @num_array, $shift_temp;
    # } elsif ($temp_array[0] % 10 == 0 && $temp_array[0] + 9 <= $temp_array[-1]) {
    #   my $shift_temp = $temp_array[0];
    #   @temp_array = grep { $_ > $shift_temp + 9 } @temp_array;
    #   chop $shift_temp;
    #   push @num_array, $shift_temp;
    } else {
      push @num_array, shift @temp_array;
    }
  }
  # say "num: " . scalar @num_array;
  $temp = join ',', @num_array;
  $value =~ s/(\d+)-(\d+)/$temp/;
}
my @values = split /[^\d]/, $value;
@values = ('') if $not_null_value && !@values;
@values = map {$prefix.$_} @values;
say for @values;
