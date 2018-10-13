#! /bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

unset VERILATOR_ROOT
ln -s /usr/bin/perl $PREFIX/bin/
autoconf
./configure \
  --prefix=$PREFIX \

make -j$CPU_COUNT
make install

# Fix hard coded paths in verilator
sed -i -e 's@^PERL = .*@PERL = /usr/bin/perl@' $PREFIX/share/verilator/include/verilated.mk
sed -i -e 's@^CXX = .*@CXX = g++@' $PREFIX/share/verilator/include/verilated.mk
sed -i -e 's@^LINK = .*@LINK = g++@' $PREFIX/share/verilator/include/verilated.mk
