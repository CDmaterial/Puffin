# 
# This test is for the 3-phase KKS model
# 

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 20
  ny = 20
  nz = 0
  xmin = 0
  xmax = 40
  ymin = 0
  ymax = 40
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
    [../]
  [../]
[]

[AuxVariables]
  [./Energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Variables]
  # concentration
  # order parameter 1
  # order parameter 2
  # order parameter 3
  # phase concentration 1
  # phase concentration 2
  # phase concentration 3
  # Lagrange multiplier
  [./c]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta1]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta2]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta3]
    # initial_condition = 0.0
    order = FIRST
    family = LAGRANGE
  [../]
  [./c1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.2
  [../]
  [./c2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.5
  [../]
  [./c3]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.8
  [../]
  [./lambda]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]
[]

[ICs]
  [./eta1]
    variable = eta1
    type = SmoothCircleIC
    x1 = 20.0
    y1 = 20.0
    radius = 10
    invalue = 0.9
    outvalue = 0.1
    int_width = 4
  [../]
  [./eta2]
    variable = eta2
    type = SmoothCircleIC
    x1 = 20.0
    y1 = 20.0
    radius = 10
    invalue = 0.1
    outvalue = 0.9
    int_width = 4
  [../]
  [./c]
    variable = c
    type = SmoothCircleIC
    x1 = 20.0
    y1 = 20.0
    radius = 10
    invalue = 0.2
    outvalue = 0.5
    int_width = 2
  [../]
[]

[Materials]
  # simple toy free energies
  # Switching functions for each phase
  # h1(eta1, eta2, eta3)
  # h2(eta1, eta2, eta3)
  # h3(eta1, eta2, eta3)
  # Coefficients for diffusion equation
  # Barrier functions for each phase
  # constant properties
  [./f1]
    type = DerivativeParsedMaterial
    f_name = F1
    args = c1
    function = 20*(c1-0.2)^2
  [../]
  [./f2]
    type = DerivativeParsedMaterial
    f_name = F2
    args = c2
    function = 20*(c2-0.5)^2
  [../]
  [./f3]
    type = DerivativeParsedMaterial
    f_name = F3
    args = c3
    function = 20*(c3-0.8)^2
  [../]
  [./h1]
    type = SwitchingFunction3PhaseMaterial
    eta_i = eta1
    eta_j = eta2
    eta_k = eta3
    f_name = h1
  [../]
  [./h2]
    type = SwitchingFunction3PhaseMaterial
    eta_i = eta2
    eta_j = eta3
    eta_k = eta1
    f_name = h2
  [../]
  [./h3]
    type = SwitchingFunction3PhaseMaterial
    eta_i = eta3
    eta_j = eta1
    eta_k = eta2
    f_name = h3
  [../]
  [./Dh1]
    type = DerivativeParsedMaterial
    material_property_names = 'D h1'
    function = D*h1
    f_name = Dh1
  [../]
  [./Dh2]
    type = DerivativeParsedMaterial
    material_property_names = 'D h2'
    function = D*h2
    f_name = Dh2
  [../]
  [./Dh3]
    type = DerivativeParsedMaterial
    material_property_names = 'D h3'
    function = D*h3
    f_name = Dh3
  [../]
  [./g1]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta1
    function_name = g1
  [../]
  [./g2]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta2
    function_name = g2
  [../]
  [./g3]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta3
    function_name = g3
  [../]
  [./constants]
    type = GenericConstantMaterial
    prop_names = 'L   kappa  D'
    prop_values = '0.7 1.0    1'
  [../]
[]

[Kernels]
  # Kernels for diffusion equation
  # Kernels for Allen-Cahn equation for eta1
  # Kernels for Allen-Cahn equation for eta2
  # Kernels for the Lagrange multiplier equation
  # Kernels for constraint equation eta1 + eta2 + eta3 = 1
  # eta3 is the nonlinear variable for the constraint equation
  # Phase concentration constraints
  [./diff_time]
    type = TimeDerivative
    variable = c
  [../]
  [./diff_c1]
    type = MatDiffusion
    variable = c
    D_name = Dh1
    conc = c1
  [../]
  [./diff_c2]
    type = MatDiffusion
    variable = c
    D_name = Dh2
    conc = c2
  [../]
  [./diff_c3]
    type = MatDiffusion
    variable = c
    D_name = Dh3
    conc = c3
  [../]
  [./deta1dt]
    type = TimeDerivative
    variable = eta1
  [../]
  [./ACBulkF1]
    type = KKSMultiACBulkF
    variable = eta1
    Fj_names = 'F1 F2 F3'
    hj_names = 'h1 h2 h3'
    gi_name = g1
    eta_i = eta1
    wi = 1.0
    args = 'c1 c2 c3 eta2 eta3'
  [../]
  [./ACBulkC1]
    type = KKSMultiACBulkC
    variable = eta1
    Fj_names = 'F1 F2 F3'
    hj_names = 'h1 h2 h3'
    cj_names = 'c1 c2 c3'
    eta_i = eta1
    args = 'eta2 eta3'
  [../]
  [./ACInterface1]
    type = ACInterface
    variable = eta1
    kappa_name = kappa
  [../]
  [./multipler1]
    type = MatReaction
    variable = eta1
    v = lambda
    mob_name = L
  [../]
  [./deta2dt]
    type = TimeDerivative
    variable = eta2
  [../]
  [./ACBulkF2]
    type = KKSMultiACBulkF
    variable = eta2
    Fj_names = 'F1 F2 F3'
    hj_names = 'h1 h2 h3'
    gi_name = g2
    eta_i = eta2
    wi = 1.0
    args = 'c1 c2 c3 eta1 eta3'
  [../]
  [./ACBulkC2]
    type = KKSMultiACBulkC
    variable = eta2
    Fj_names = 'F1 F2 F3'
    hj_names = 'h1 h2 h3'
    cj_names = 'c1 c2 c3'
    eta_i = eta2
    args = 'eta1 eta3'
  [../]
  [./ACInterface2]
    type = ACInterface
    variable = eta2
    kappa_name = kappa
  [../]
  [./multipler2]
    type = MatReaction
    variable = eta2
    v = lambda
    mob_name = L
  [../]
  [./mult_lambda]
    type = MatReaction
    variable = lambda
    mob_name = 3
  [../]
  [./mult_ACBulkF_1]
    type = KKSMultiACBulkF
    variable = lambda
    Fj_names = 'F1 F2 F3'
    hj_names = 'h1 h2 h3'
    gi_name = g1
    eta_i = eta1
    wi = 1.0
    mob_name = 1
    args = 'c1 c2 c3 eta2 eta3'
  [../]
  [./mult_ACBulkC_1]
    type = KKSMultiACBulkC
    variable = lambda
    Fj_names = 'F1 F2 F3'
    hj_names = 'h1 h2 h3'
    cj_names = 'c1 c2 c3'
    eta_i = eta1
    args = 'eta2 eta3'
    mob_name = 1
  [../]
  [./mult_CoupledACint_1]
    type = SimpleCoupledACInterface
    variable = lambda
    v = eta1
    kappa_name = kappa
    mob_name = 1
  [../]
  [./mult_ACBulkF_2]
    type = KKSMultiACBulkF
    variable = lambda
    Fj_names = 'F1 F2 F3'
    hj_names = 'h1 h2 h3'
    gi_name = g2
    eta_i = eta2
    wi = 1.0
    mob_name = 1
    args = 'c1 c2 c3 eta1 eta3'
  [../]
  [./mult_ACBulkC_2]
    type = KKSMultiACBulkC
    variable = lambda
    Fj_names = 'F1 F2 F3'
    hj_names = 'h1 h2 h3'
    cj_names = 'c1 c2 c3'
    eta_i = eta2
    args = 'eta1 eta3'
    mob_name = 1
  [../]
  [./mult_CoupledACint_2]
    type = SimpleCoupledACInterface
    variable = lambda
    v = eta2
    kappa_name = kappa
    mob_name = 1
  [../]
  [./mult_ACBulkF_3]
    type = KKSMultiACBulkF
    variable = lambda
    Fj_names = 'F1 F2 F3'
    hj_names = 'h1 h2 h3'
    gi_name = g3
    eta_i = eta3
    wi = 1.0
    mob_name = 1
    args = 'c1 c2 c3 eta1 eta2'
  [../]
  [./mult_ACBulkC_3]
    type = KKSMultiACBulkC
    variable = lambda
    Fj_names = 'F1 F2 F3'
    hj_names = 'h1 h2 h3'
    cj_names = 'c1 c2 c3'
    eta_i = eta3
    args = 'eta1 eta2'
    mob_name = 1
  [../]
  [./mult_CoupledACint_3]
    type = SimpleCoupledACInterface
    variable = lambda
    v = eta3
    kappa_name = kappa
    mob_name = 1
  [../]
  [./eta3reaction]
    type = MatReaction
    variable = eta3
    mob_name = 1
  [../]
  [./eta1reaction]
    type = MatReaction
    variable = eta3
    v = eta1
    mob_name = 1
  [../]
  [./eta2reaction]
    type = MatReaction
    variable = eta3
    v = eta2
    mob_name = 1
  [../]
  [./one]
    type = BodyForce
    variable = eta3
    value = -1.0
  [../]
  [./chempot12]
    type = KKSPhaseChemicalPotential
    variable = c1
    cb = c2
    fa_name = F1
    fb_name = F2
  [../]
  [./chempot23]
    type = KKSPhaseChemicalPotential
    variable = c2
    cb = c3
    fa_name = F2
    fb_name = F3
  [../]
  [./phaseconcentration]
    type = KKSMultiPhaseConcentration
    variable = c3
    cj = 'c1 c2 c3'
    hj_names = 'h1 h2 h3'
    etas = 'eta1 eta2 eta3'
    c = c
  [../]
[]

[AuxKernels]
  [./Energy_total]
    type = KKSMultiFreeEnergy
    Fj_names = 'F1 F2 F3'
    hj_names = 'h1 h2 h3'
    gj_names = 'g1 g2 g3'
    variable = Energy
    w = 1
    interfacial_vars = 'eta1  eta2  eta3'
    kappa_names = 'kappa kappa kappa'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -sub_pc_type   -sub_pc_factor_shift_type'
  petsc_options_value = 'asm       ilu            nonzero'
  l_max_its = 30
  nl_max_its = 10
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-10
  nl_abs_tol = 1.0e-11
  num_steps = 20
  dt = 0.5
[]

[Preconditioning]
  active = 'full'
  [./full]
    type = SMP
    full = true
  [../]
  [./mydebug]
    type = FDP
    full = true
  [../]
[]

[Outputs]
  exodus = true
[]

