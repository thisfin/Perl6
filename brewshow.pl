#!/usr/bin/env perl6

use v6;

my %mappingHash = ('build' => 'Build:', 'required' => 'Required:', 'recommended' => 'Recommended:');

my %moduleHash;
for run('brew', 'list', :out).out.words -> $moduleName {
    my %valueHash;
    for run('brew', 'info', $moduleName, :out).out.lines -> $line {
        given $line {
            for %mappingHash.kv -> $mappingName, $regex {
                when /$regex/ {
                    %valueHash.push($mappingName => ~$/.postmatch.subst(/\s/, '', :g).split(/\,/));
                }
            }
        }
    }
    %moduleHash.push($moduleName => %valueHash);
}

for %moduleHash.keys -> $key {
	say $key, ' ', %moduleHash{$key};
}
say %moduleHash.elems;
