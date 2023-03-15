use godot::prelude::*;

mod bullet;
mod damage_number;
struct PastaRogueLike;

#[gdextension]
unsafe impl ExtensionLibrary for PastaRogueLike {}
