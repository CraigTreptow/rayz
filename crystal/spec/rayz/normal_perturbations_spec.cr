require "../spec_helper"

module Rayz
  describe NormalPerturbations do
    it "sine_wave returns a proc" do
      perturb = NormalPerturbations.sine_wave
      delta = perturb.call(Point.new(0.0, 1.0, 0.0))
      delta.is_a?(Vector).should be_true
    end

    it "sine_wave produces non-zero perturbation for non-origin point" do
      perturb = NormalPerturbations.sine_wave(frequency: 10.0, amplitude: 0.1)
      delta = perturb.call(Point.new(1.0, 1.0, 1.0))
      (delta.x.abs + delta.y.abs + delta.z.abs).should be > 0.0
    end

    it "quilted returns a proc" do
      perturb = NormalPerturbations.quilted
      delta = perturb.call(Point.new(1.0, 0.0, 1.0))
      delta.is_a?(Vector).should be_true
    end

    it "noise returns a proc" do
      perturb = NormalPerturbations.noise
      delta = perturb.call(Point.new(1.0, 1.0, 1.0))
      delta.is_a?(Vector).should be_true
    end

    it "ripples returns a proc" do
      perturb = NormalPerturbations.ripples
      delta = perturb.call(Point.new(1.0, 0.0, 0.0))
      delta.is_a?(Vector).should be_true
    end

    it "normal_perturbation on material is nil by default" do
      m = Material.new
      m.normal_perturbation.should be_nil
    end

    it "applying a perturbation changes the normal" do
      s = Sphere.new
      s.material.normal_perturbation = NormalPerturbations.sine_wave(frequency: 20.0, amplitude: 0.3)
      pt = Point.new(0.0, 1.0, 0.0)
      n_perturbed = s.normal_at(pt)
      n_plain = Sphere.new.normal_at(pt)
      n_perturbed.should_not eq(n_plain)
    end

    it "perturbed normal is still normalized" do
      s = Sphere.new
      s.material.normal_perturbation = NormalPerturbations.noise(frequency: 8.0, amplitude: 0.2)
      n = s.normal_at(Point.new(1.0, 0.0, 0.0))
      n.magnitude.should be_close(1.0, 1e-5)
    end

    it "zero perturbation leaves normal unchanged" do
      s = Sphere.new
      s.material.normal_perturbation = NormalPerturbations.sine_wave(frequency: 10.0, amplitude: 0.0)
      pt = Point.new(0.0, 1.0, 0.0)
      n_perturbed = s.normal_at(pt)
      n_plain = Sphere.new.normal_at(pt)
      n_perturbed.x.should be_close(n_plain.x, 1e-5)
      n_perturbed.y.should be_close(n_plain.y, 1e-5)
      n_perturbed.z.should be_close(n_plain.z, 1e-5)
    end
  end
end
