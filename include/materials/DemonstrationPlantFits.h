/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADMaterial.h"

/**
 * A material that couples a material property
 */
class DemonstrationPlantFits : public ADMaterial
{
public:
  static InputParameters validParams();

  DemonstrationPlantFits(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  const Real _c_mu0;
  const Real _c_mu1;
  const Real _c_mu2;
  const Real _c_mu3;
  const Real _Tmax;
  const Real _Tl;
  const Real _T90;
  const Real _beta;
  const Real _c_k0;
  const Real _c_k1;
  const Real _c_cp0;
  const Real _c_cp1;
  const Real _c_rho0;
  const ADVariableValue & _temperature;
  const ADVariableGradient & _grad_temperature;
  ADMaterialProperty<Real> & _mu;
  ADMaterialProperty<Real> & _k;
  ADMaterialProperty<Real> & _cp;
  ADMaterialProperty<Real> & _rho;
  ADMaterialProperty<RealVectorValue> & _grad_k;

  const Real _length_units_per_meter;
  const Real _temperature_units_per_kelvin;
  const Real _mass_units_per_kilogram;
  const Real _time_units_per_second;
};
