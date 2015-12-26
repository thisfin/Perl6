#!/usr/bin/env perl6

use v6;

class Model {
    has @.builds;
    has @.requireds;
    has @.recommendeds;
}

sub splitline($line) {
    return $line.subst(/\s/, '', :g).split(/\,/);
}

my $proc = run 'brew', 'list', :out;
my @modules = $proc.out.words;
my %moduleHash;
for @modules -> $module {
    my $m = Model.new;
    $proc = run 'brew', 'info', $module, :out;
    for $proc.out.lines -> $line {
        given $line {
            when /Build\:/ {
                $m.builds = splitline(~$/.postmatch);
            }
            when /Required\:/ {
                $m.requireds = splitline(~$/.postmatch);
            }
            say $line;
            when /Recommended\:/ {
                $m.recommendeds = splitline(~$/.postmatch);
            }
        }
    }
    # last;
    %moduleHash.push($module => $m);
}

my %resultHash;
for %moduleHash.kv -> $key, $value {
    for $value.builds -> $build {
        my $m = %resultHash{$build};
        if !$m  {
            $m = Model.new;
            %resultHash.push($build, $m);
        }
        $m.builds.push($key);
    }
    for $value.requireds -> $required {
        my $m = %resultHash{$required};
        if !$m  {
            $m = Model.new;
            %resultHash.push($required, $m);
        }
        $m.requireds.push($key);
    }
    for $value.recommendeds -> $recommended {
        my $m = %resultHash{$recommended};
        if !$m  {
            $m = Model.new;
            %resultHash.push($recommended, $m);
        }
        $m.recommendeds.push($key);
    }
}

for %moduleHash.keys -> $key {
    #say $key, %moduleHash{$key};
    say $key, ' ', %resultHash{$key};
}
say %moduleHash.elems;
