# Oxomoco
## aka "How Not To Do Gravity"

When I was 17, I was taught, formally, the law of gravitation. So, of course, I hacked together a 2D gravity simulator in [Löve] in my spare time! And as it turns out, two years later in University, I got an assignment to make what was, essentially, this but with a few bits more. Neat, huh?

![The Earth, as it appears to move about the Moon's reference frame. The simulation zooms out and shows the Sun, and simulation speeds up to show its more flower-like path](https://images.squarespace-cdn.com/content/v1/5dbf4ceb23861854274c5a15/1572846759769-VSOGURMFWC71X8Y91BND/ke17ZwdGBToddI8pDm48kHTltL2lmdnsJxFL_LED5_FZw-zPPgdn4jUwVcJE1ZvWEtT5uBSRWt4vQZAgTJucoTqqXjS3CfNDSuuf31e0tVGsg7I3aR9l36tvEixSmJtkpbMOeVpyzg_lzaMSRJTOf1tO8nJtk629tZGIWiyY3XQ/yizzy-orbit-perspectives.gif?format=1000w)

It's **completely a toy project,** but it has:

- reference frames, showing you different paths _in different reference frames!_
- A renderer for the gravitational field strength, which is CPU-bound so a lil slow 
- A neat grid system which fades in different grid sizes as you zoom (`Scrollwheel`)!
- A simulation speed slider (`Shift+Scrollwheel`), which has no simulation speed limit so you can very quickly go into the Unphysical Realm and fling the Moon into the great beyond!
- The ability to move things around in real-time, or add random comets, and see how they, ah, destabilise things!

I never got to include the Solar System with accurate orbits (because I was a _kid_), but I still think this is pretty neat considering I was 2017 and, like, barely sentient. Clearly so, because this thing runs its own object-oriented engine and physics.

## Instructions

Download [Löve], extract this to a folder of your choice, and run `love path/to/oxomoco`. You might need an older version to run without bugs, sorry.

In addition to the tools available on 1, 2, 3 and 6, the following controls exist:

* `Space`: pause and play simulation
* `Scrollwheel`: zoom in and out
* `Shift-scrollwheel`: Make time run faster or slower
* `F5`: Restart
* `F11`: Fullscreen
* `9`: Go into grid move
* `8`: Show gravitational field strength (press `F2` to render - it's slow!)
* `D`: Toggle debug display
* `T`: Toggle body titles
* `P`: Toggle paths
* `C`: Toggle connections between bodies
* `V`: Toggle velocity vector
* `B`: Toggle body

[Löve]: https://love2d.org

### License

<p xmlns:dct="http://purl.org/dc/terms/" xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#">
  <a rel="license"
     href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="https://licensebuttons.net/p/zero/1.0/80x15.png" style="border-style: none;" alt="CC0" />
  </a>
  2017 – 2019.
  To the extent possible under law,
  <a rel="dct:publisher"
     href="https://yunru.se">
    <span property="dct:title">Mia yun Ruse</span></a>
  has waived all copyright and related or neighboring rights to
  <span property="dct:title">Oxomoco</span>.
  <span property="vcard:Country" datatype="dct:ISO3166" content="GB" about="https://yunru.se"></span>.
</p>
