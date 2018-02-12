#!/usr/bin/perl

# Run this program like
# cat data.csv | ./parser.pl > output.csv
# To parse data.csv into output.csv

use Data::Dumper qw(Dumper);

sub pad {
  return sprintf("%02d", @_);
}

sub pad3 {
  return sprintf("%03d", @_);
}

sub pad4 {
  return sprintf("%04d", @_);
}

sub year {
  if (@_ < 18) {
    return 20;
  }
    return 19;
}

sub effectiveDate {
  my ($data) = @_;
  if ($data =~ /^(\d{1,2})\/(\d{1,2})\/(\d{1,2})$/) {
    # Validate that the month is between 1-12
    # Validate that the days is between 1-31
    if ($1 >= 1 && $1 <= 12 && $2 >= 1 && $2 <= 31) {
      return pad($1) . qq(/) . pad($2) . qq(/) . year($3) . pad($3) ;
    }
  }
  return "error"
}

sub processStatus {
  my ($data) = @_;
  # Validate $data has up to 5 characters
  # NOTE: Correctly Gives an error for Change as Change is 6 characters
  if ($data =~ /^(\w{1,5})$/) {
    return $1;
  }
  return "error"
}

sub processClientId {
  my ($data) = @_;
  # validate that client ID is 6 digits
  if ($data =~ /^(\d{6})$/) {
    return $1;
  }
  return "error"
}

sub process2Digits {
  my ($data) = @_;
  if ($data =~ /^(\d{1,2})$/) {
    return pad($1);
  }
  return "error"
}

sub process3Digits {
  my ($data) = @_;
  if ($data =~ /^(\d{1,3})$/) {
    return pad3($1);
  }
  return "error"
}

sub process4Digits {
  my ($data) = @_;
  if ($data =~ /^(\d{1,4})$/) {
    return pad4($1);
  }
  return "error"
}

#incomplete
sub processSSN {
  my ($data) = @_;
  $_ = $data;
  s/-//;
  return $_;
}

#incomplete
sub processEmail {
  my ($data) = @_;
  if ($data =~ /\w+@\w+\.\w+/) {
    return $1;
  }
  return "error"
}

sub processRelationship {
  my ($data) = @_;
  if ($data =~ /[PSCD]{1}/) {
    return $1;
  }
  return "error"
}

sub processProductId {
  my ($data) = @_;
  if ($data =~ /[PAP|PA]{1}/) {
    return $1;
  }
  return "error"
}

sub printRecord {
  my (@cols) = @_;
  print effectiveDate($cols[0]) . ',' .
    processStatus($cols[1]) . ',' .
    $cols[2] . ',' .
    processClientId($cols[3]) . ',' .
    $cols[4] . ',' .
    $cols[5] . ',' .
    $cols[6] . ',' .
    $cols[7] . ',' .
    process2Digits($cols[8]) . ',' .
    process2Digits($cols[9]) . ',' .
    process4Digits($cols[10]) . ',' .
    $cols[21] . ',' .
    "\n";
}

# Read from stdin - must pipe CSV into program
my @deps;

while(<STDIN>) {
  # Split each line into an array by commas
  my @cols = split /,/;
  # See what is in each array
  # print Dumper \@cols;
  # Process the date (first element in the @cols array)

  #  print processClientId($cols[3]) . "\n";

  # Once everything is written, chain them all together for the output
  if ($cols[21] =~ /P/) {
    printRecord(@cols);
  }
  else {
    # Push a reference to the columns array onto dependents for later printing
    push @deps, \@cols;
  }
}

foreach (@deps) {
  # Print the dependent data by dereferencing the saved column array
  printRecord(@{$_});
}


