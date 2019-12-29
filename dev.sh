rm -rf build
mkdir build && cd build
meson --prefix /usr ..
ninja -j$(nproc)
sudo ninja install
cd ..
budgie-panel --replace &
