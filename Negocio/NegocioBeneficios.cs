using System;
using System.Collections.Generic;
using Dominio;
using Dominio.Enums;

namespace Negocio
{
    public class NegocioBeneficios
    {
        // Catálogo fijo del complejo, ordenado por umbral para mostrarlo como una escalera.
        public List<BeneficioFidelidad> ObtenerActivos()
        {
            List<BeneficioFidelidad> lista = new List<BeneficioFidelidad>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.SetearConsulta(@"
                    SELECT IDBeneficio, Nombre, Descripcion, ReservasRequeridas,
                           IDTipoDescuento, ValorDescuento, DiasValidez, Activo
                    FROM BeneficiosFidelidad
                    WHERE Activo = 1
                    ORDER BY ReservasRequeridas");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    BeneficioFidelidad b = new BeneficioFidelidad();
                    b.IdBeneficio = (int)datos.Lector["IDBeneficio"];
                    b.Nombre = (string)datos.Lector["Nombre"];
                    b.Descripcion = (string)datos.Lector["Descripcion"];
                    b.ReservasRequeridas = (int)datos.Lector["ReservasRequeridas"];
                    b.TipoDescuento = (TipoDescuento)(int)datos.Lector["IDTipoDescuento"];
                    b.ValorDescuento = datos.Lector["ValorDescuento"] is DBNull ? (decimal?)null : (decimal)datos.Lector["ValorDescuento"];
                    b.DiasValidez = datos.Lector["DiasValidez"] is DBNull ? (int?)null : (int)datos.Lector["DiasValidez"];
                    b.Activo = (bool)datos.Lector["Activo"];
                    lista.Add(b);
                }
                return lista;
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
    }
}
