## first attempt to set up mesh, units in meters

ram_spacer_radius = 0.031

punch_radius = 0.006
punch_height = 0.020

powder_radius = 0.006
powder_height = 0.005163

die_wall_inner_radius = 0.006125
die_wall_outer_radius = 0.020
die_wall_height = 0.030

contact_scale_factor = 1.0e-4

#######################################################################################
### Calculated values from user-provided results
ram_spacer_surface_area = '${fparse pi * ram_spacer_radius * ram_spacer_radius}'
punch_surface_area = ${fparse pi * punch_radius * punch_radius}
# # ram_spacer_overhang_offset = ${fparse ram_spacer_radius - ram_spacer_overhang_radius}
# ram_cc_spacers_height = '${fparse ram_spacer_height + cc_spacer_height}'
# ram_cc_sinter_spacers_height = '${fparse ram_cc_spacers_height + sinter_spacer_height}'
# ram_cc_sinter_punch_height = '${fparse ram_cc_sinter_spacers_height + punch_height}'
stack_with_powder = '${fparse punch_height + powder_height}'

[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = false
[]

[Mesh]
  [bottom_punch]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 21
    ny = 39 #38 # 43 #42
    xmax = ${punch_radius}
    ymin = 0.0
    ymax = ${punch_height}
    boundary_name_prefix = 'bottom_punch'
    elem_type = QUAD8
  []
  [bottom_punch_block]
    type = SubdomainIDGenerator
    input = bottom_punch
    subdomain_id = 4
  []

  [powder]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 17
    ny = 14
    xmax = ${powder_radius}
    ymin = ${punch_height}
    ymax = ${stack_with_powder}
    boundary_name_prefix = powder
    elem_type = QUAD8
    boundary_id_offset = 4
  []
  [powder_block]
    type = SubdomainIDGenerator
    input = powder
    subdomain_id = 5
  []

  [top_punch]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 21
    ny = 39 #38 # 43 #42
    xmax = ${punch_radius}
    ymin = ${stack_with_powder}
    ymax = '${fparse stack_with_powder + punch_height}'
    boundary_name_prefix = 'top_punch'
    elem_type = QUAD8
    boundary_id_offset = 8
  []
  [top_punch_block]
    type = SubdomainIDGenerator
    input = top_punch
    subdomain_id = 6
  []


  [die_wall]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 51 #31 #21
    ny = 151 #87 #43
    xmin = ${die_wall_inner_radius}
    xmax = ${die_wall_outer_radius}
    ymin = '${fparse punch_height + (powder_height - die_wall_height) / 2.0}'
    ymax = '${fparse punch_height + (powder_height + die_wall_height) / 2.0}'
    boundary_name_prefix = die_wall
    elem_type = QUAD8
    boundary_id_offset = 12
  []
  [die_wall_block]
    type = SubdomainIDGenerator
    input = 'die_wall'
    subdomain_id = 10
  []

  [four_blocks]
    type = MeshCollectionGenerator
    inputs = 'bottom_punch_block powder_block top_punch_block die_wall_block'
  []
  [block_rename]
    type = RenameBlockGenerator
    input = four_blocks
    old_block = '4 5 6 10'
    new_block = 'bottom_punch powder top_punch die_wall'
  []

  [uncovered_bottom_punch_right]
    type = SideSetsFromBoundingBoxGenerator
    input = block_rename
    bottom_left = '${fparse punch_radius - 1.0e-3} -1.0e-4 0.0'
    top_right = '${fparse punch_radius + 1.0e-3} ${fparse punch_height + (powder_height - die_wall_height) / 2.0 - 1.0e-4} 0.0'
    boundary_new = 'uncovered_bottom_punch_right'
    included_boundaries = 'bottom_punch_right'
  []
  [uncovered_top_punch_right]
    type = SideSetsFromBoundingBoxGenerator
    input = uncovered_bottom_punch_right
    bottom_left = '${fparse punch_radius - 1.0e-3} ${fparse punch_height + (powder_height + die_wall_height) / 2.0 + 1.0e-4} 0.0'
    top_right = '${fparse punch_radius + 1.0e-3} ${fparse stack_with_powder + punch_height - 1.0e-4} 0.0'
    boundary_new = 'uncovered_top_punch_right'
    included_boundaries = 'top_punch_right'
  []
  patch_update_strategy = iteration
  patch_size = 100 #50 ##40 is the default size
  second_order = true
  coord_type = RZ
[]

[Problem]
  type = ReferenceResidualProblem
  reference_vector = 'ref'
  extra_tag_vectors = 'ref'
  converge_on = 'disp_x disp_y temperature potential'
  # group_variables = 'disp_x disp_y'
[]

[Variables]
  [disp_x]
    block = 'bottom_punch powder top_punch die_wall'
    order = SECOND
  []
  [disp_y]
    block = 'bottom_punch powder top_punch die_wall'
    order = SECOND
  []
  [temperature]
    initial_condition = 300.0
    block = 'bottom_punch powder top_punch die_wall'
    order = SECOND
  []
  [potential]
    block = 'bottom_punch powder top_punch die_wall'
    order = SECOND
  []

  [temperature_bottom_punch_powder_lm]
    block = ' bottom_punch_powder_secondary_subdomain'
    # initial_condition = 300.0
    order = SECOND
    use_dual = true
  []
  [potential_bottom_punch_powder_lm]
    block = 'bottom_punch_powder_secondary_subdomain'
    order = SECOND
    use_dual = true
  []
  [temperature_powder_top_punch_lm]
    block = 'powder_top_punch_secondary_subdomain'
    # initial_condition = 300.0
    order = SECOND
    use_dual = true
  []
  [potential_powder_top_punch_lm]
    block = ' powder_top_punch_secondary_subdomain'
    order = SECOND
    use_dual = true
  []

  [temperature_inside_low_punch_lm]
    block = 'inside_low_punch_secondary_subdomain'
    # initial_condition = 300.0
    order = SECOND
    use_dual = true
  []
  [potential_inside_low_punch_lm]
    block = 'inside_low_punch_secondary_subdomain'
    order = SECOND
    use_dual = true
  []
  [temperature_inside_powder_lm]
    block = 'inside_powder_secondary_subdomain'
    # initial_condition = 300.0
    order = SECOND
    use_dual = true
  []
  [potential_inside_powder_lm]
    block = 'inside_powder_secondary_subdomain'
    order = SECOND
    use_dual = true
  []
  [temperature_inside_top_punch_lm]
    block = 'inside_top_punch_secondary_subdomain'
    # initial_condition = 300.0
    order = SECOND
    use_dual = true
  []
  [potential_inside_top_punch_lm]
    block = 'inside_top_punch_secondary_subdomain'
    order = SECOND
    use_dual = true
  []
[]

[AuxVariables]
  [heat_transfer_radiation]
    order = SECOND
  []

  [electric_field_x]
    family = MONOMIAL #prettier pictures with smoother values
    order = FIRST
    block = 'bottom_punch powder top_punch die_wall'
  []
  [electric_field_y]
    family = MONOMIAL
    order = FIRST
    block = 'bottom_punch powder top_punch die_wall'
  []

  [interface_punch_lm]
    order = FIRST
    family = LAGRANGE
    block = 'bottom_punch_powder_secondary_subdomain
             powder_top_punch_secondary_subdomain'
    initial_condition = '${fparse (346 * 9.8067) / (pi * punch_radius * punch_radius)}'
  []
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [graphite]
        strain = FINITE
        incremental = true
        add_variables = false
        use_automatic_differentiation = true
        extra_vector_tags = 'ref'
        generate_output = 'strain_xx strain_xy strain_yy stress_xx stress_xy stress_yy vonmises_stress'
        eigenstrain_names = graphite_thermal_expansion
        block = 'bottom_punch top_punch die_wall'
      []
      [iron]
        strain = FINITE
        incremental = true
        add_variables = false
        use_automatic_differentiation = true
        extra_vector_tags = 'ref'
        generate_output = 'strain_xx strain_xy strain_yy stress_xx stress_xy stress_yy vonmises_stress'
        eigenstrain_names = iron_thermal_expansion
        block = 'powder'
      []
    []
  []
[]

[Kernels]
  [HeatDiff_graphite]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = graphite_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'bottom_punch top_punch die_wall'
  []
  [HeatTdot_graphite]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = graphite_heat_capacity
    density_name = graphite_density
    extra_vector_tags = 'ref'
    block = 'bottom_punch top_punch die_wall'
  []
  [electric_graphite]
    type = ADHeatConduction
    variable = potential
    thermal_conductivity = graphite_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'bottom_punch top_punch die_wall'
 []
  [JouleHeating_graphite]
    type = ADJouleHeatingSource
    variable = temperature
    heating_term = graphite_electric_field_heating
    use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'bottom_punch top_punch die_wall'
  []

  [HeatDiff_powder]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = iron_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'powder'
  []
  [HeatTdot_powder]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = iron_heat_capacity
    density_name = iron_density
    extra_vector_tags = 'ref'
    block = 'powder'
  []
  [electric_powder]
    type = ADHeatConduction
    variable = potential
    thermal_conductivity = iron_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'powder'
  []
  [JouleHeating_powder]
    type = ADJouleHeatingSource
    variable = temperature
    heating_term = iron_electric_field_heating
    use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'powder'
  []
[]

[AuxKernels]
  [heat_transfer_radiation]
    type = ParsedAux
    variable = heat_transfer_radiation
    boundary = 'uncovered_bottom_punch_right die_wall_right uncovered_top_punch_right'
    coupled_variables = 'temperature'
    constant_names = 'boltzmann epsilon temperature_farfield' #published emissivity for graphite is 0.85
    constant_expressions = '5.67037e-8 0.85 300.0' #roughly room temperature, which is probably too cold
    expression = '-boltzmann*epsilon*(temperature^4-temperature_farfield^4)'
  []

  [electrostatic_calculation_x]
    type = PotentialToFieldAux
    gradient_variable = potential
    variable = electric_field_x
    sign = negative
    component = x
    block = 'bottom_punch powder top_punch die_wall'
  []
  [electrostatic_calculation_y]
    type = PotentialToFieldAux
    gradient_variable = potential
    variable = electric_field_y
    sign = negative
    component = y
    block = 'bottom_punch powder top_punch die_wall'
  []
[]

[Functions]
  [dcs5_current]
    type = PiecewiseLinear
    data_file = 'dcs5_15Nov2023_FeCTErun.csv'
    y_title = 'DCCurrent_A'
    format = COLUMNS
    scale_factor = '${fparse 1.0/ram_spacer_surface_area}'
  []
  [dcs5_force]
    type = PiecewiseLinear
    data_file = 'dcs5_15Nov2023_FeCTErun.csv'
    y_title = 'HydraulicRamForce_kgf'
    format = COLUMNS
    scale_factor = ${fparse 9.8067/ punch_surface_area} ## gravity, to convert to Pa
  []
  [dcs5_topRam_temperature]
    type = PiecewiseLinear
    data_file = 'dcs5_15Nov2023_FeCTErun.csv'
    y_title = 'Overtemp_C'
    format = COLUMNS
  []
  [dcs5_bottomRam_temperature]
    type = PiecewiseLinear
    data_file = 'dcs5_15Nov2023_FeCTErun.csv'
    y_title = 'ProcessTC2_C'
    format = COLUMNS
  []
  [top_ram_heat_temperature]
    type = ParsedFunction
    expression = '(tempC + 273.15)'
    symbol_names = 'tempC'
    symbol_values = 'dcs5_topRam_temperature '
  []
  [bottom_ram_temperature]
    type = ParsedFunction
    expression = 'tempC + 273.15'
    symbol_names = 'tempC'
    symbol_values = 'dcs5_bottomRam_temperature'
  []
[]

[BCs]
  [fixed_bottom_edge]
    type = ADDirichletBC
    variable = disp_y
    value = 0
    boundary = 'bottom_punch_bottom die_wall_bottom'
  []
  [pressure_top_ram]
    type = ADPressure
    variable = disp_y
    boundary = 'top_punch_top'
    function = 'dcs5_force'
  []
  [fixed_centerline]
    type = ADDirichletBC
    variable = disp_x
    value = 0
    boundary = 'bottom_punch_left powder_left top_punch_left'
  []

  [temperature_top_ram]
    type = ADFunctionDirichletBC
    variable = temperature
    function = 'top_ram_heat_temperature'
    boundary = 'top_punch_top'
  []
  [temperature_bottom_ram]
    type = ADFunctionDirichletBC
    variable = temperature
    function = 'bottom_ram_temperature'
    boundary = 'bottom_punch_bottom'
  []
  [external_surface_temperature]
    type = CoupledVarNeumannBC
    variable = temperature
    v = heat_transfer_radiation
    boundary = 'uncovered_bottom_punch_right die_wall_right uncovered_top_punch_right'
  []
  [electric_bottom]
    type = ADFunctionNeumannBC
    variable = potential
    function = 'dcs5_current' #'current_application'
    boundary = 'bottom_punch_bottom'
  []
  [electric_top]
    type = ADDirichletBC
    variable = potential
    value = 0.0
    boundary = 'top_punch_top'
  []
[]

[Contact]
  [bottom_punch_powder]
    primary = bottom_punch_top
    secondary = powder_bottom
    model = frictionless
    c_normal = 1e8
    # normal_lm_scaling = 1e-6
    formulation = mortar
    correct_edge_dropping = true
    use_dual = false
    extra_vector_tags = 'ref'
  []

  [powder_top_punch]
    primary = powder_top
    secondary = top_punch_bottom
    model = frictionless
    c_normal = 1e8
    # normal_lm_scaling = 1e-6
    formulation = mortar
    correct_edge_dropping = true
    use_dual = false
    extra_vector_tags = 'ref'
  []

  [inside_low_punch]
    primary = die_wall_left
    secondary = bottom_punch_right
    model = frictionless
    c_normal = 1e8
    # normal_lm_scaling = 1e-6
    formulation = mortar
    # correct_edge_dropping = true
    use_dual = false
    extra_vector_tags = 'ref'
  []
  [inside_powder]
    primary = die_wall_left
    secondary = powder_right
    model = frictionless
    c_normal = 1e8 #might need to keep this one to prevent powder moving into the die wall
    # normal_lm_scaling = 1e-6
    formulation = mortar
    correct_edge_dropping = true
    use_dual = false
    extra_vector_tags = 'ref'
  []
  [inside_top_punch]
    primary = die_wall_left
    secondary = top_punch_right
    model = frictionless
    c_normal = 1e8
    # normal_lm_scaling = 1e-6
    formulation = mortar
    # correct_edge_dropping = true
    use_dual = false
    extra_vector_tags = 'ref'
  []
[]

[Constraints]
  [thermal_contact_interface_low_punch_powder]
    type = ModularGapConductanceConstraint
    variable = temperature_bottom_punch_powder_lm
    secondary_variable = temperature
    primary_boundary = bottom_punch_top
    primary_subdomain = bottom_punch_powder_primary_subdomain
    secondary_boundary = powder_bottom
    secondary_subdomain = bottom_punch_powder_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_bottom_punch_powder'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact_interface_low_punch_powder]
    type = ModularGapConductanceConstraint
    variable = potential_bottom_punch_powder_lm
    secondary_variable = potential
    primary_boundary = bottom_punch_top
    primary_subdomain = bottom_punch_powder_primary_subdomain
    secondary_boundary = powder_bottom
    secondary_subdomain = bottom_punch_powder_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_bottom_punch_powder'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [thermal_contact_interface_powder_top_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_powder_top_punch_lm
    secondary_variable = temperature
    primary_boundary = powder_top
    primary_subdomain = powder_top_punch_primary_subdomain
    secondary_boundary = top_punch_bottom
    secondary_subdomain = powder_top_punch_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_powder_top_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact_interface_powder_top_punch]
    type = ModularGapConductanceConstraint
    variable = potential_powder_top_punch_lm
    secondary_variable = potential
    primary_boundary = powder_top
    primary_subdomain = powder_top_punch_primary_subdomain
    secondary_boundary = top_punch_bottom
    secondary_subdomain = powder_top_punch_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_powder_top_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []

  [thermal_contact_interface_inside_die_low_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_inside_low_punch_lm
    secondary_variable = temperature
    primary_boundary = die_wall_left
    primary_subdomain = inside_die_primary_subdomain
    secondary_boundary = bottom_punch_right
    secondary_subdomain = inside_low_punch_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'thermal_conduction_wall_low_punch' # closed_thermal_interface_inside_die_low_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact_interface_inside_die_low_punch]
    type = ModularGapConductanceConstraint
    variable = potential_inside_low_punch_lm
    secondary_variable = potential
    primary_boundary = die_wall_left
    primary_subdomain = inside_die_primary_subdomain
    secondary_boundary = bottom_punch_right
    secondary_subdomain = inside_low_punch_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'electrical_conduction_wall_low_punch' # closed_electric_interface_inside_die_low_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [thermal_contact_interface_inside_die_powder]
    type = ModularGapConductanceConstraint
    variable = temperature_inside_powder_lm
    secondary_variable = temperature
    primary_boundary = die_wall_left
    primary_subdomain = inside_die_primary_subdomain
    secondary_boundary = powder_right
    secondary_subdomain = inside_powder_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'thermal_conduction_wall_powder' # closed_thermal_interface_inside_die_powder'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact_interface_inside_die_powder]
    type = ModularGapConductanceConstraint
    variable = potential_inside_powder_lm
    secondary_variable = potential
    primary_boundary = die_wall_left
    primary_subdomain = inside_die_primary_subdomain
    secondary_boundary = powder_right
    secondary_subdomain = inside_powder_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'electrical_conduction_wall_powder' # closed_electric_interface_inside_die_powder'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [thermal_contact_interface_inside_die_top_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_inside_top_punch_lm
    secondary_variable = temperature
    primary_boundary = die_wall_left
    primary_subdomain = inside_die_primary_subdomain
    secondary_boundary = top_punch_right
    secondary_subdomain = inside_top_punch_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'thermal_conduction_wall_top_punch' # closed_thermal_interface_inside_die_top_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact_interface_inside_die_top_punch]
    type = ModularGapConductanceConstraint
    variable = potential_inside_top_punch_lm
    secondary_variable = potential
    primary_boundary = die_wall_left
    primary_subdomain = inside_die_primary_subdomain
    secondary_boundary = top_punch_right
    secondary_subdomain = inside_top_punch_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'electrical_conduction_wall_top_punch' # closed_electric_interface_inside_die_top_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
[]

[Materials]
  [graphite_electro_thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'graphite_density graphite_thermal_conductivity graphite_heat_capacity graphite_electrical_conductivity graphite_hardness'
    prop_values = '        1.82e3           81                            1.303e3                5.88e4                           1.0'
    block = 'bottom_punch top_punch die_wall inside_low_punch_secondary_subdomain inside_top_punch_secondary_subdomain'
    # density (kg/m^3), thermal conductivity (W/m-K), and electrical conductivity (S/m) from manufacture datasheet for G535,
    #           available at http://schunk-tokai.pl/pl/wp-content/uploads/Schunk-Tokai-2015-englisch.pdf
    # specific heat capacity for IG110 graphite, https://www.nrc.gov/docs/ML2121/ML21215A346.pdf, equation on pg A-40 at 293K,
  []
  [graphite_em_heating_material]
    type = ElectromagneticHeatingMaterial
    electric_field = potential
    electric_field_heating_name = graphite_electric_field_heating
    electrical_conductivity = graphite_electrical_conductivity
    formulation = 'time'
    solver = 'electrostatic'
    block = 'bottom_punch top_punch die_wall'
  []
  [graphite_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 1.08e10 #in Pa, http://schunk-tokai.pl/pl/wp-content/uploads/Schunk-Tokai-2015-englisch.pdf
    poissons_ratio = 0.33
    block = 'bottom_punch top_punch die_wall'
  []
  [graphite_stress]
    type = ADComputeFiniteStrainElasticStress
    block = 'bottom_punch top_punch die_wall'
  []
  [graphite_thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 5.5e-6 # G535 datasheet, http://schunk-tokai.pl/pl/wp-content/uploads/Schunk-Tokai-2015-englisch.pdf
    stress_free_temperature = 300.0
    temperature = temperature
    eigenstrain_name = 'graphite_thermal_expansion'
    block = 'bottom_punch top_punch die_wall'
  []

  [iron_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 2.0e11 #in Pa, https://www.matweb.com/search/DataSheet.aspx?MatGUID=654ca9c358264b5392d43315d8535b7d&ckck=1
    poissons_ratio = 0.291
    block = 'powder'
  []
  [iron_stress]
    type = ADComputeFiniteStrainElasticStress
    block = 'powder'
  []
  [iron_thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 15.0e-6 # https://www.matweb.com/search/DataSheet.aspx?MatGUID=654ca9c358264b5392d43315d8535b7d&ckck=1
    stress_free_temperature = 300.0
    temperature = temperature
    eigenstrain_name = 'iron_thermal_expansion'
    block = 'powder'
  []
  [iron_density_powder]
    type = ADGenericConstantMaterial
    prop_names = 'iron_density'
    prop_values = 7874.0
    #Density data from K. C. Mills, "Recommended values of thermophysical properties for selected
    #commercial alloys", in units of kg/m^3 at 298K
    output_properties = 'iron_density'
    outputs = exodus
    block = 'powder bottom_punch_powder_secondary_subdomain powder_top_punch_secondary_subdomain
             inside_powder_secondary_subdomain'
  []
  [iron_heat_capacity_powder]
    type = ADGenericConstantMaterial
    prop_names = 'iron_heat_capacity'
    prop_values = '   25.09'
    #Value at 298K, heat capacity in units of J/mol/K
    #https://webbook.nist.gov/cgi/cbook.cgi?ID=C7439896&Units=SI&Mask=2&Type=JANAFS&Table=on
    output_properties = 'iron_heat_capacity'
    outputs = exodus
    block = 'powder bottom_punch_powder_secondary_subdomain powder_top_punch_secondary_subdomain
             inside_powder_secondary_subdomain'
  []

  [iron_electrical_conductivity_powder]
    type = ADGenericConstantMaterial
    prop_names = 'iron_electrical_conductivity'
    prop_values = '9.876e6'
    #Data from Fulkerson et al., J. Applied Physics, 37, pp. 2639-2653 (1966)
    #Table VII, ORNL high purity samples
    #conductivity in units of S/m at 298K
    output_properties = 'iron_electrical_conductivity'
    outputs = exodus
    block = 'powder bottom_punch_powder_secondary_subdomain powder_top_punch_secondary_subdomain
             inside_powder_secondary_subdomain'
  []
  [iron_em_heating_material]
    type = ElectromagneticHeatingMaterial
    electric_field = potential
    electric_field_heating_name = iron_electric_field_heating
    electrical_conductivity = iron_electrical_conductivity
    formulation = 'time'
    solver = 'electrostatic'
    block = powder
  []

  [iron_thermal_conductivity_powder]
    type = ADGenericConstantMaterial
    prop_names = iron_thermal_conductivity
    prop_values = '2.711e4'
    #Data from Fulkerson et al., J. Applied Physics, 37, pp. 2639-2653 (1966)
    #Table III, ORNL high purity samples, piecewise curve fit this work
    #thermal conductivity in units of W/m-K at 298K
    output_properties = 'iron_thermal_conductivity'
    outputs = exodus
    block = 'powder bottom_punch_powder_secondary_subdomain powder_top_punch_secondary_subdomain
             inside_powder_secondary_subdomain'
  []

  [iron_electro_thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'iron_hardness'
    prop_values = '   1.0' # assumed unity to remove influence of hardenss
    block = 'powder bottom_punch_powder_secondary_subdomain powder_top_punch_secondary_subdomain
             inside_powder_secondary_subdomain'
  []
[]

[UserObjects]
  [closed_thermal_interface_bottom_punch_powder]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = iron_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_punch_lm #bottom_punch_powder_normal_lm
    scaling_coefficient = ${contact_scale_factor}
    primary_hardness = graphite_hardness
    secondary_hardness = iron_hardness
    boundary = powder_bottom
  []
  [closed_electric_interface_bottom_punch_powder]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = iron_electrical_conductivity
    temperature = potential
    contact_pressure = interface_punch_lm #bottom_punch_powder_normal_lm
    scaling_coefficient = ${contact_scale_factor}
    primary_hardness = graphite_hardness
    secondary_hardness = iron_hardness
    boundary = powder_bottom
  []
  [closed_thermal_interface_powder_top_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = iron_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_punch_lm #powder_top_punch_normal_lm
    scaling_coefficient = ${contact_scale_factor}
    primary_hardness = graphite_hardness
    secondary_hardness = iron_hardness
    boundary = top_punch_bottom
  []
  [closed_electric_interface_powder_top_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = iron_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_punch_lm #powder_top_punch_normal_lm
    scaling_coefficient = ${contact_scale_factor}
    primary_hardness = iron_hardness
    secondary_hardness = graphite_hardness
    boundary = top_punch_bottom
  []

  [thermal_conduction_wall_low_punch]
    type = GapFluxModelConduction
    temperature = temperature
    boundary = bottom_punch_right
    gap_conductivity = 5 #ceramaterials, through thickness
    use_displaced_mesh = true
  []
  [electrical_conduction_wall_low_punch]
    type = GapFluxModelConduction
    temperature = potential
    boundary = bottom_punch_right
    gap_conductivity = 1.429e5 #from ceramaterials datasheet, converted from resistivity
    use_displaced_mesh = true
  []
  [closed_thermal_interface_inside_die_low_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = inside_low_punch_normal_lm
    scaling_coefficient = ${contact_scale_factor}
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = bottom_punch_right
  []
  [closed_electric_interface_inside_die_low_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = inside_low_punch_normal_lm
    scaling_coefficient = ${contact_scale_factor}
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = bottom_punch_right
  []
  [thermal_conduction_wall_powder]
    type = GapFluxModelConduction
    temperature = temperature
    boundary = powder_right
    gap_conductivity = 5 #ceramaterials, through thickness
    use_displaced_mesh = true
  []
  [electrical_conduction_wall_powder]
    type = GapFluxModelConduction
    temperature = potential
    boundary = powder_right
    gap_conductivity = 1.429e5 #from ceramaterials datasheet, converted from resistivity
    use_displaced_mesh = true
  []
  [closed_thermal_interface_inside_die_powder]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = iron_thermal_conductivity
    temperature = temperature
    contact_pressure = inside_powder_normal_lm
    scaling_coefficient = ${contact_scale_factor}
    primary_hardness = graphite_hardness
    secondary_hardness = iron_hardness
    boundary = powder_right
  []
  [closed_electric_interface_inside_die_powder]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = iron_electrical_conductivity
    temperature = potential
    contact_pressure = inside_powder_normal_lm
    scaling_coefficient = ${contact_scale_factor}
    primary_hardness = graphite_hardness
    secondary_hardness = iron_hardness
    boundary = powder_right
  []
  [thermal_conduction_wall_top_punch]
    type = GapFluxModelConduction
    temperature = temperature
    boundary = top_punch_right
    gap_conductivity = 5 #ceramaterials, through thickness
    use_displaced_mesh = true
  []
  [electrical_conduction_wall_top_punch]
    type = GapFluxModelConduction
    temperature = potential
    boundary = top_punch_right
    gap_conductivity = 1.429e5 #from ceramaterials datasheet, converted from resistivity
    use_displaced_mesh = true
  []
  [closed_thermal_interface_inside_die_top_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = inside_top_punch_normal_lm
    scaling_coefficient = ${contact_scale_factor}
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_punch_right
  []
  [closed_electric_interface_inside_die_top_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = inside_top_punch_normal_lm
    scaling_coefficient = ${contact_scale_factor}
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_punch_right
  []
[]

[Postprocessors]
  [top_ram_displacement]
    type = SideAverageValue
    boundary = 'top_punch_top'
    variable = disp_y
  []
  [applied_force]
    type = FunctionValuePostprocessor
    function = dcs5_force
  []
  [applied_current_density]
    type = FunctionValuePostprocessor
    function = dcs5_current #current_application
  []

  [powder_potential]
    type = PointValue
    variable = potential
    point = '${fparse powder_radius / 2.0} ${fparse punch_height + powder_height / 2.0} 0'
    use_displaced_mesh = false
  []
  [pyrometer_point]
    type = PointValue
    variable = temperature
    point = '0.01375 ${fparse punch_height + powder_height / 2.0} 0'
    use_displaced_mesh = false
  []

  [vmstress_bot_punch]
    type = ADElementAverageMaterialProperty
    mat_prop = vonmises_stress
    block = bottom_punch
  []
  [vmstress_top_punch]
    type = ADElementAverageMaterialProperty
    mat_prop = vonmises_stress
    block = top_punch
  []
  [vmstress_powder]
    type = ADElementAverageMaterialProperty
    mat_prop = vonmises_stress
    block = powder
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  automatic_scaling = false
  line_search = 'none'

  # # force running options
  # petsc_options_iname = '-pc_type -snes_linesearch_type -pc_factor_shift_type -pc_factor_shift_amount'
  # petsc_options_value = 'lu       basic                 NONZERO               1e-15'

  # mortar contact solver options
  petsc_options = '-pc_svd_monitor' #-snes_converged_reason
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_type' # -pc_factor_shift_type'
  petsc_options_value = ' lu       superlu_dist' # NONZERO'
  snesmf_reuse_base = false

  nl_rel_tol = 1e-6 #1e-6 #1e-8 couldn't converge with 1e-3 dt in the first timestep in 20 nl iterations
  nl_abs_tol = 2e-8 # couldn't converge past the first timestep on temperature #1e-10
  nl_max_its = 25
  nl_forced_its = 2
  l_max_its = 50

  # start_time = 90
  dtmax = 1.0
  dtmin = 1.0e-8
  end_time = 1600
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.1
    optimal_iterations = 10
    iteration_window = 2
    force_step_every_function_point = true
    timestep_limiting_function = dcs5_current
  []
[]

[Outputs]
  color = false
  csv = true
  perf_graph = true
  [exodus]
    type = Exodus
    min_simulation_time_interval = 1.0
  []
[]
