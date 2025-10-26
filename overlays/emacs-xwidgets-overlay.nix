# Overlay to build Emacs with GTK3 and Xwidgets support.
# I prefer the overlay approach as the other NixOS options were causing conflicts.
# Note: Xwidgets currently crashes unless started with: `emacs -xrm "emacs.synchronous: true"`

self: super:

let
  # Use the correct version of webkitgtk
  webkitgtk = super.webkitgtk_4_0 or super.webkitgtk;
in
{
  emacs = super.emacs.overrideAttrs (oldAttrs: {
    configureFlags = (oldAttrs.configureFlags or []) ++ [
      "--with-xwidgets"
      "--with-x-toolkit=gtk3"
    ];

    buildInputs = (oldAttrs.buildInputs or []) ++ [ webkitgtk ];
  });
}
