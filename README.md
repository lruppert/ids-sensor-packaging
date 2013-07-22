ids-sensor-packaging
====================

These are rough Debian packaging materials and diffs to official Debian 
packaging materials to allow me to maintain a pf_ring-based IDS sensor 
collection.

For pf_ring and friends: just copy the pf_ring/debian directory in place, 
create a changelog entry for the version you're working with and you're ready
to go.

For bro: just copy the bro/debian directory into place, create a changelog
entry for the version you're working with and you're ready to go.

For suricata: If you're running Debian squeeze, apply the diffs and you should
be good to go. For wheezy you might not need it.
