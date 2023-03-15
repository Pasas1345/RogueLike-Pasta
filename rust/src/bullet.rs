use godot::{prelude::*, engine::{Area2D, Engine}};

#[derive(GodotClass)]
#[class(base=Area2D)]
pub struct Bullet {
	#[export(getter = "get_speed", setter = "set_speed")]
	pub speed: real,
	#[export(getter = "get_damage", setter = "set_damage")]
	pub damage: real,
	#[export(getter = "get_oneshot", setter = "set_oneshot")]
	pub one_shot: bool,

	#[base]
	base: Base<Area2D>
}

#[godot_api]
impl Bullet {
	#[func]
	fn on_bullet_body_entered(&mut self, _body: Gd<Node2D>) {
        if self.base.share().has_node("hitbox_custom".into()) {
            let custom_hitbox = self.base.get_node_as::<Area2D>("hitbox_custom");
			// Expect Pasas to have a queue free after hes done with this function. ISTG if he doesn't.
			custom_hitbox.share().call("_custom_hit".into(), &[self.damage.to_variant()]);
        }
		else {
			if _body.share().has_method(("change_health").into()) {
				_body.share().call("change_health".into(), &[(-self.damage).to_variant()]);
	
				if self.one_shot {
					self.base.queue_free();
				}
			}
		}
	}

	// Getters and Setters (because export needs those apparently)
	#[func]
	pub fn get_speed(&self) -> real {
		self.speed
	}
	#[func]
	pub fn set_speed(&mut self, val: real) {
		self.speed = val
	}
	#[func]
	pub fn get_damage(&self) -> real {
		self.damage
	}
	#[func]
	pub fn set_damage(&mut self, val: real) {
		self.damage = val
	}
	#[func]
	pub fn get_oneshot(&self) -> bool {
		self.one_shot
	}
	#[func]
	pub fn set_oneshot(&mut self, val: bool) {
		self.one_shot = val
	}
}

#[godot_api]
impl GodotExt for Bullet {
	fn init(base: Base<Area2D>) -> Self {
		Bullet {
			speed: 200.0,
			damage: 20.0,
			one_shot: true,
			base
		}
	}

	fn ready(&mut self)  {
		self.base.share().connect("body_entered".into(), Callable::from_object_method(self.base.share(), "on_bullet_body_entered"), 0);
	}

	fn physics_process(&mut self, delta: f64) {
		if !Engine::singleton().is_editor_hint() {
			let forward = self.base.get_global_transform().a;
	
			let change = forward * self.speed * real::from_f64(delta);

			let new_pos = self.base.get_global_position() + change;
			
			self.base.set_global_position(new_pos)
		}
	}
}
