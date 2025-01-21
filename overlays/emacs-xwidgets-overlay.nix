# Overlay to build Emacs with GTK3 and Xwidgets support.
# I prefers the overlay approach as the other nixos approaches where causing conflicts.
# Nowdays, xwidgets crashes unless started: `emacs -xrm "emacs.synchronous: true"`.
self: super:

let
  emacsWithGTK3AndXwidgets = super.emacs.override {
    withGTK3 = true;
    withXwidgets = true;
  };
in
{
  emacs = emacsWithGTK3AndXwidgets;
}
