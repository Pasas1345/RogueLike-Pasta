use godot::{prelude::*, engine::{Label, AnimationPlayer, Engine}};

#[derive(GodotClass)]
#[class(base=Node2D)]
pub struct DamageNumber {
	#[export(getter = "get_damage", setter = "set_damage")]
	pub damage: real,
	pub label: Gd<Label>,

	#[base]
	base: Base<Node2D>
}

#[godot_api]
impl DamageNumber {
	#[func]
	fn begin(&mut self) {
		let mut animation_player = self.base.get_node_as::<AnimationPlayer>("Animation");

		self.label.share().set_text(format!("{}", self.get_damage()).into());

		animation_player.play("damage".into(), -1.0, 1.0, false);
	}

	#[func]
	fn get_damage(&mut self) -> real {
		self.damage
	}

	#[func]
	fn set_damage(&mut self, dmg: real) {
		self.damage = dmg
	}
}

#[godot_api]
impl GodotExt for DamageNumber {
	fn init(base: Base<Node2D>) -> Self {
		DamageNumber { 
			damage: 10.0, 
			label: Label::new_alloc(), 
			base
		}
	}

	fn ready(&mut self) {
		if !Engine::singleton().is_editor_hint() {
			self.label = self.base.share().get_node_as::<Label>("Label");
		}
	}
}