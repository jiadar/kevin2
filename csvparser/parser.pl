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

sub pad5 {
  return sprintf("%05d", @_);
}
sub pad6 {
  return sprintf("%07d", @_);
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
  return "Date error"
}

sub processStatus {
  my ($data) = @_;
  # Validate $data has up to 5 characters
  # NOTE: Correctly Gives an error for Change as Change is 6 characters
  if ($data =~ /^(\w{1,5})$/) {
    return $1;
  }
  return "Status error"
}

sub processClientId {
  my ($data) = @_;
  # validate that client ID is 6 digits
  if ($data =~ /^(\d{6})$/) {
    return $1;
  }
  return "6digits error"
}

sub process2Digits {
  my ($data) = @_;
  if ($data =~ /^(\d{1,2})$/) {
    return pad($1);
  }
  return "2digits error"
}

sub process3Digits {
  my ($data) = @_;
  if ($data =~ /^(\d{1,3})$/) {
    return pad3($1);
  }
  return "3digits error"
}

sub process4Digits {
  my ($data) = @_;
  if ($data =~ /^(\d{1,4})$/) {
    return pad4($1);
  }
  return "4digits error"
}


sub processSSN {
  my ($data) = @_;
  $_ = $data; 
  if ($data = {s/-//}) {
    return $_;
  }
  return "SSN error";
}

sub process5Digits {
  my ($data) = @_;
  if ($data =~ /^(\d{1,5})$/) {
    return pad5($1);
  }
  return "5 digits error"
}

sub processPhone {
  my ($data) = @_;
  if ($data =~ /\d{3}(\d{3})(\d{4})/) { # fixed to detect just local part of phone number
    return "$1-$2";  # return local part of phone number
  }
  return "phone error"
}

#incomplete
sub processEmail {
  my ($data) = @_;
  $_ = $data; 
  if ($data =~ /\w+@\w+\.\w+/) {
    return $_;
  }
  
}

sub processRelationship {
  my ($data) = @_;
  if ($data =~ /([PSCD])/) {
    return $1;
  }
  return "Relationship error"
}
sub processProductId {
  my ($data) = @_;
  # Check optional fields like this
  if ($data =~ /(PAP|PA)/) { # took out the []
    return $1;
  }
  #print Dumper $data; # this is how I found it was a newline
  if ($data =~ /\n/) { # check for newline (empty)
    return '';
  }
  if (! $data) { # check for empty
    return '';
  }
  return "ProductID Error"
}

# wrote this - there is no family/individual process
sub processPlanType {
  my ($data) = @_;
  if ($data =~ /(Individual|Family)/) { # took out the []
    return $1
  }
  return "PlanType Error"
}

# Wrote this there was no processPrimary
sub processPrimary {
  my ($data) = @_;
  if ($data =~ /([Y|N])/) {
    return $1
  }
  return "Primary Error"
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
    processSSN($cols[7]) . ',' .
    process2Digits($cols[8]) . ',' .
    process2Digits($cols[9]) . ',' .
    process4Digits($cols[10]) . ',' .
    $cols[11] . ','  .
    $cols[13] . ',' .
    $cols[14] . ',' .
    process5Digits($cols[15]) . ',' .
    process3Digits($cols[16]) . ',' .
    processPhone($cols[17]) . ',' . # this wants you to chop the phone to 7 digits
    processEmail($cols[18]) . ',' .
    $cols[19] . ',' .
    $cols[20] . ',' . # was missing "customer-defined" column
    processRelationship($cols[21]) . ',' . # changed to 21
    processPrimary($cols[22]) . ',' . # changed to 22, wrote process primary
    $cols[23] . ',' . # added
    $cols[24] . ',' . # added
    processPlanType($cols[25]) . ',' .
    processProductId($cols[26]) .
    "\n";
}

# Read from stdin - must pipe CSV into program
my @deps;

# Set a flag to test if we have read the header row or not
my $read_header_row = 0;

# Print the header row as the first thing we print
print "Effective Date,", "Status,", "EmployeeID,", "ClientID,", "MemberFirstName,", "MemberMiddleName,",
  "MemberLastName,", "MemberSSN,", "DOB_Month,", "DOB_Day,", "DOB_Year,", "Address1,", "Address2,", "City,",
  "State,", "ZipCode,", "AreaCode,", "HomePhone,", "Email,", "Deduction Method,", "Customer-Defined,",
  "Relationship,", "Primary,", "FamilyID,", "UniqueID,", "Plan_Type,", "ProductID\n";

while(<STDIN>) {
  # If we have not read the header row, skip processing this line
  if (! $read_header_row) {
    $read_header_row = 1;
  }
  # Otherwise, we have already read the header row, so process
  else {
    # Split each line into an array by commas
    my @cols = split /,/;
    # See what is in each array
    # print Dumper \@cols;
    # Process the date (first element in the @cols array)

    #  print processClientId($cols[3]) . "\n";

    # Once everything is written, chain them all together for the output
    # Push a reference to the columns array onto dependents for later printing
    if ($cols[21] =~ /P/) {
      printRecord(@cols)
    }
    else {
      push @deps, \@cols;
    }
  }
}
foreach (@deps) {
  # Print the dependent data by dereferencing the saved column array
  printRecord(@{$_});
}

