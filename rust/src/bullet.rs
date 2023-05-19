use godot::{prelude::*, engine::{Area2D, Engine, Area2DVirtual}};

#[derive(GodotClass)]
#[class(base=Area2D)]
pub struct Bullet {
	#[export]
	pub speed: real,
	#[export]
	pub damage: real,
	#[export]
	pub one_shot: bool,
	#[export]
	pub filter: Gd<Node2D>,
	
	#[base]
	base: Base<Area2D>,
}

#[godot_api]
impl Bullet {
	#[func]
	fn on_bullet_body_entered(&mut self, _body: Gd<Node2D>) {
		if !Engine::singleton().is_editor_hint() {
			if self.filter != Node2D::new_alloc() {
				self.hit(_body);
			}
			else {
				if self.filter == _body {
					self.hit(_body);
				}
			}

		}
	}

	#[func]
	fn hit(&mut self, _body: Gd<Node2D>) {
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

	#[func]
	fn expire(&mut self) {
		if !Engine::singleton().is_editor_hint() {
			if self.base.share().has_node("hitbox_custom".into()) {
				let custom_hitbox = self.base.get_node_as::<Area2D>("hitbox_custom");
				// Expect Pasas to have a queue free after hes done with this function. ISTG if he doesn't.
				custom_hitbox.share().call("_custom_hit".into(), &[self.damage.to_variant()]);
			}
			else {
				self.base.queue_free();
			}
		}
	}
}

#[godot_api]
impl Area2DVirtual for Bullet {
	fn init(base: Base<Area2D>) -> Self {
		Bullet {
			speed: 200.0,
			damage: 20.0,
			one_shot: true,
			filter: Node2D::new_alloc(),
			base
		}
	}

	fn ready(&mut self)  {
		if !Engine::singleton().is_editor_hint() {
			self.base.share().connect("body_entered".into(), Callable::from_object_method(self.base.share(), "on_bullet_body_entered"), 0);
			let mut timer = self.get_tree().unwrap().create_timer(5.0, false, false, false).unwrap();

			timer.connect("timeout".into(), Callable::from_object_method(self.base.share(), "expire"), 0);
		}
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
