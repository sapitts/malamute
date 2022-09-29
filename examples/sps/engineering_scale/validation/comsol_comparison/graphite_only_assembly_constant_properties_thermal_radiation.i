### Initial conditions, common variables
initial_temperature = 293.15

## Units in the input file: m-Pa-s-K

[GlobalParams]
  order = SECOND
[]

[Mesh]
  [graphite_assembly]
    type = FileMeshGenerator
    file = graphite_only_comparison_2d.e
  []
  [pyrometer_node]
    type = ExtraNodesetGenerator
    coord = '0.013605 0 0'
    new_boundary = 'pyrometer_node'
    input = graphite_assembly
  []
  coord_type = RZ
  construct_side_list_from_node_list = true
[]

[Problem]
  type = ReferenceResidualProblem
  reference_vector = 'ref'
  extra_tag_vectors = 'ref'
[]

[Variables]
  [temperature]
    initial_condition = ${initial_temperature}
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [electric_potential]
    # block = '1 2 3 4 5 6 7 8 9'
  []
[]

[AuxVariables]
  [electric_field_x]
    family = MONOMIAL #prettier pictures with smoother values
    order = FIRST
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [electric_field_y]
    family = MONOMIAL
    order = FIRST
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [current_density]
    family = NEDELEC_ONE
    order = FIRST
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [E_x]
    order = FIRST
    family = MONOMIAL
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [E_y]
    order = FIRST
    family = MONOMIAL
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [electrical_conductivity]
    family = MONOMIAL
    order = FIRST
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [thermal_conductivity]
    family = MONOMIAL
    order = FIRST
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [heatflux_graphite_x]
    family = MONOMIAL
    order = FIRST
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [heatflux_graphite_y]
    family = MONOMIAL
    order = FIRST
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [heat_transfer_radiation]
    # block = '1 2 3 4 5 6 7 8 9'
  []
[]

[Kernels]
  [HeatDiff_graphite]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = thermal_conductivity
    extra_vector_tags = 'ref'
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [HeatTdot_graphite]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = heat_capacity
    density_name = density
    extra_vector_tags = 'ref'
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [JouleHeating_graphite]
    type = ADJouleHeatingSource
    variable = temperature
    elec = electric_potential
    electrical_conductivity = electrical_conductivity
    # use_displaced_mesh = true
    extra_vector_tags = 'ref'
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [electric_graphite]
    type = ADMatDiffusion
    variable = electric_potential
    diffusivity = electrical_conductivity
    extra_vector_tags = 'ref'
    # block = '1 2 3 4 5 6 7 8 9'
  []
[]

[AuxKernels]
  [electrostatic_calculation_x_graphite]
    type = PotentialToFieldAux
    gradient_variable = electric_potential
    variable = electric_field_x
    sign = negative
    component = x
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [electrostatic_calculation_y_graphite]
    type = PotentialToFieldAux
    gradient_variable = electric_potential
    variable = electric_field_y
    sign = negative
    component = y
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [current_density_graphite]
    type = ADCurrentDensity
    variable = current_density
    potential = electric_potential
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [E_x]
    type = VariableGradientComponent
    variable = E_x
    gradient_variable = electric_potential
    component = x
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [E_y]
    type = VariableGradientComponent
    variable = E_y
    gradient_variable = electric_potential
    component = y
    # block = '1 2 3 4 5 6 7 8 9'
  []

  [heat_flux_graphite_x]
    type = DiffusionFluxAux
    diffusivity = nonad_thermal_conductivity
    diffusion_variable = temperature
    variable = heatflux_graphite_x
    component = x
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [heat_flux_graphite_y]
    type = DiffusionFluxAux
    diffusivity = nonad_thermal_conductivity
    diffusion_variable = temperature
    variable = heatflux_graphite_y
    component = y
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [heat_transfer_radiation_graphite]
    type = ParsedAux
    variable = heat_transfer_radiation
    boundary = 'exterior_surface'
    args = 'temperature'
    constant_names = 'boltzmann epsilon temperature_farfield' #published emissivity for graphite is 0.85
    constant_expressions = '5.67e-8 0.8 293.15' #roughly room temperature, which is probably too cold
    function = 'boltzmann*epsilon*(temperature_farfield^4-temperature^4)'
  []
  [thermal_conductivity_graphite]
    type = ADMaterialRealAux
    variable = thermal_conductivity
    property = thermal_conductivity
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [electrical_conductivity_graphite]
    type = ADMaterialRealAux
    variable = electrical_conductivity
    property = electrical_conductivity
    # block = '1 2 3 4 5 6 7 8 9'
  []
[]

[BCs]
  [external_surface_graphite]
    type = CoupledVarNeumannBC
    boundary = 'exterior_surface'
    variable = temperature
    v = heat_transfer_radiation
  []

  [temperature_ram_spacer_extremes]
    type = ADDirichletBC
    variable = temperature
    boundary = 'upper_ram_spacer_top lower_ram_spacer_bottom'
    value = ${initial_temperature}
  []
  # [electric_potential_top]
  #   type = ADFunctionNeumannBC
  #   variable = electric_potential
  #   boundary = top
  #   ## This will need to be updated to match the Dr. Sinter geometry
  #   function = 'if(t < 31, (980 / (pi * 0.000961))*((0.141301/4.3625)*t), if(t > 600, 0, 980 / (pi * 0.000961)))' # RMS Current / Cross-sectional Area. Ramping for t < 31s approximately reflects Cincotti et al (DOI: 10.1002/aic.11102) Figure 21(b)
  # []
  [electric_potential_top]
    type = ADDirichletBC
    variable = electric_potential
    boundary = upper_ram_spacer_top
    value = 3
  []
  [electric_potential_bottom]
    type = ADDirichletBC
    variable = electric_potential
    boundary = lower_ram_spacer_bottom
    value = 0
  []
[]

[Materials]
  ## graphite blocks
  [graphite_density]
    type = ADGenericConstantMaterial
    prop_names = 'electrical_conductivity thermal_conductivity density heat_capacity'
    prop_values = '  5.88e4                 81                 1.82e3    1.5e3'
    # block = '1 2 3 4 5 6 7 8 9'
  []

  # Material property converter for DiffusionFluxAux object
  [converter]
    type = MaterialADConverter
    ad_props_in = thermal_conductivity
    reg_props_out = nonad_thermal_conductivity
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  automatic_scaling = true
  line_search = 'none'
  # compute_scaling_once = false

  # force running options
  # petsc_options_iname = '-pc_type -snes_linesearch_type -pc_factor_shift_type -pc_factor_shift_amount'
  # petsc_options_value = 'lu       basic                 NONZERO               1e-15'

  # #mechanical contact options
  # petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       superlu_dist'
  petsc_options = '-snes_converged_reason -ksp_converged_reason'

  nl_forced_its = 1
  nl_rel_tol = 1e-6 #1e-6 #2e-5 for with mechanics #was 1e-10, for temperature only
  nl_abs_tol = 1e-12 #was 1e-12
  nl_max_its = 20
  l_max_its = 50
  # dtmin = 1.0e-4
  dtmax = 500

  end_time = 3000 #600 #900 #15 minutes, rule of thumb from Dennis is 10 minutes

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.05
    optimal_iterations = 8
    iteration_window = 2
  []
[]

[Postprocessors]
  [temperature_pp]
    type = AverageNodalVariableValue
    variable = temperature
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [graphite_thermal_conductivity]
    type = ElementAverageValue
    variable = thermal_conductivity
    # block = '1 2 3 4 5 6 7 8 9'
  []
  [graphite_electrical_conductivity]
    type = ElementAverageValue
    variable = electrical_conductivity
    block = '1 2 3 4 5 6 7 8 9'
  []
  [pyrometer_node]
    type = NodalVariableValue
    variable = temperature
    nodeid = 9579 #paraview 9580 at (0.013605, 0, 0)
  []
  [pyrometer_nodeset]
    type = AverageNodalVariableValue
    variable = temperature
    boundary = pyrometer_node
  []
  [pyrometer_point]
    type = PointValue
    variable = temperature
    point = '0.01375 0 0'
  []
  # [pyrometer_node_potential]
  #   type = NodalVariableValue
  #   variable = electric_potential
  #   nodeid = 9579 #paraview 9580 at (0.013605, 0, 0)
  # []
  # [pyrometer_point_potential]
  #   type = PointValue
  #   variable = electric_potential
  #   point = '0.01375 0 0'
  #   use_displaced_mesh = false
  # []
[]

[Outputs]
  csv = true
  exodus = true
  perf_graph = true
  # [ckpt]
  #   type =Checkpoint
  #   interval = 1
  #   num_files = 2
  # []
[]
