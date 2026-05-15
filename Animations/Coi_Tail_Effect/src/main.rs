use nannou::prelude::*;
use nannou_egui::{self, egui, Egui};

struct Model {
    t: f32,
    egui: Egui,
    speed: f32,
    base_radius: f32,
    alpha: u8,
    hue_shift: f32,
}

fn main() {
    nannou::app(model).update(update).view(view).run();
}

fn model(app: &App) -> Model {
    let window_id = app
        .new_window()
        .size(800, 800)
        .raw_event(raw_window_event)
        .build()
        .unwrap();

    let window = app.window(window_id).unwrap();
    let egui = Egui::from_window(&window);

    Model {
        t: 0.0,
        egui,
        speed: 0.013,
        base_radius: 1.6,
        alpha: 140,
        hue_shift: 0.0,
    }
}

fn update(_app: &App, model: &mut Model, update: Update) {
    model.t += model.speed;

    model.egui.set_elapsed_time(update.since_start);
    let _ = model.egui.begin_frame();

    let ctx = model.egui.ctx();
    egui::Window::new("🎛️ Frond Controls").show(&ctx, |ui| {
        ui.heading("Animation");
        ui.add(egui::Slider::new(&mut model.speed, 0.001..=0.1).text("Speed"));
        ui.add(egui::Slider::new(&mut model.base_radius, 0.5..=5.0).text("Particle Size"));

        ui.separator();
        ui.heading("Color");
        ui.add(egui::Slider::new(&mut model.alpha, 30..=255).text("Opacity"));
        ui.add(egui::Slider::new(&mut model.hue_shift, 0.0..=1.0).text("Hue Shift"));

        if ui.button("Reset Animation").clicked() {
            model.t = 0.0;
        }
    });
}

fn raw_window_event(_app: &App, model: &mut Model, event: &nannou::winit::event::WindowEvent) {
    model.egui.handle_raw_event(event);
}

fn view(app: &App, model: &Model, frame: Frame) {
    let draw = app.draw();
    draw.background().color(rgb8(10, 10, 15));

    let time = model.t;

    for i in 0..14000 {
        let x = i as f32;
        let y = i as f32 / 235.0;

        let k = 4.0 * (x / 21.0).cos();
        let e = y / 8.0 - 20.0;
        let d = (k * k + e * e).sqrt();

        let q = 3.0 * (k * 2.0).sin()
            + 0.3 / if k.abs() < 0.01 { 0.01 } else { k }
            + (y / 19.0).sin() * k
                * (9.0 + 2.0 * (e * 14.0 - d * 3.0 + time * 2.0).sin());

        let c = d - time * 1.8;
        let px = q + 3.0 * c.sin() + 50.0 * c.cos();
        let py = q * c.sin() + d * 39.0 - 475.0;

        let radius = if k * k > 15.0 {
            model.base_radius * 1.3
        } else {
            model.base_radius
        };

        let color = hsla(model.hue_shift, 0.85, 0.92, model.alpha as f32 / 255.0);

        draw.ellipse()
            .xy(vec2(px, -py))
            .radius(radius)
            .color(color);
    }

    draw.to_frame(app, &frame).unwrap();
    model.egui.draw_to_frame(&frame).unwrap();
}
