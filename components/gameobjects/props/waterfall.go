components {
  id: "waterfall_splash"
  component: "/components/particlefx/waterfall_splash.particlefx"
  position {
    y: -1.0
  }
}
embedded_components {
  id: "model"
  type: "model"
  data: "mesh: \"/builtins/assets/meshes/quad_2x2.dae\"\n"
  "name: \"{{NAME}}\"\n"
  "materials {\n"
  "  name: \"default\"\n"
  "  material: \"/components/materials/waterfall.material\"\n"
  "  textures {\n"
  "    sampler: \"tex0\"\n"
  "    texture: \"/assets/uniform_clouds_512.png\"\n"
  "  }\n"
  "}\n"
  ""
}
