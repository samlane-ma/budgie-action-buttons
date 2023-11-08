# Budgie Action Buttons

## User Customizable buttons for the Budgie Desktop Raven panel

### WIP - Currently non-functional

Dependencies

* gtk+-3.0
* budgie-raven-plugin-1.0
* libpeas-gtk-1.0

To install (for Debian/Ubuntu):

    mkdir build
    cd build
    meson setup --prefix=/usr --libdir=/usr/lib
    ninja
    sudo ninja install

Logout / Login may be needed before the widget can be added to allow an installed schema to be recognized.
