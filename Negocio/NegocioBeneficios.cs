using System;
using System.Collections.Generic;
using Dominio;
using Dominio.Enums;

namespace Negocio
{
    public class NegocioBeneficios
    {
        // Catálogo fijo del complejo, ordenado por umbral para mostrarlo como una escalera.
        // Solo los vigentes: lo consume la vista del cliente ("En camino").
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
                    lista.Add(Mapear(datos));
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

        // Todos los beneficios (activos e inactivos), para la pantalla de administración.
        // Activos primero; dentro de cada grupo, por umbral creciente.
        public List<BeneficioFidelidad> ObtenerTodos()
        {
            List<BeneficioFidelidad> lista = new List<BeneficioFidelidad>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.SetearConsulta(@"
                    SELECT IDBeneficio, Nombre, Descripcion, ReservasRequeridas,
                           IDTipoDescuento, ValorDescuento, DiasValidez, Activo
                    FROM BeneficiosFidelidad
                    ORDER BY Activo DESC, ReservasRequeridas");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    lista.Add(Mapear(datos));
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

        public BeneficioFidelidad ObtenerPorId(int idBeneficio)
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.SetearConsulta(@"
                    SELECT IDBeneficio, Nombre, Descripcion, ReservasRequeridas,
                           IDTipoDescuento, ValorDescuento, DiasValidez, Activo
                    FROM BeneficiosFidelidad
                    WHERE IDBeneficio = @id");
                datos.AgregarParametro("@id", idBeneficio);
                datos.EjecutarLectura();

                if (datos.Lector.Read())
                    return Mapear(datos);

                return null;
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

        public void Agregar(BeneficioFidelidad b)
        {
            AccesoDatos datos = new AccesoDatos();

            datos.SetearConsulta(@"
                INSERT INTO BeneficiosFidelidad
                    (Nombre, Descripcion, ReservasRequeridas, IDTipoDescuento,
                     ValorDescuento, DiasValidez, Activo)
                VALUES
                    (@nombre, @desc, @reservas, @tipo, @valor, @dias, 1)");
            CargarParametros(datos, b);
            datos.EjecutarAccion();
        }

        public void Modificar(BeneficioFidelidad b)
        {
            AccesoDatos datos = new AccesoDatos();

            datos.SetearConsulta(@"
                UPDATE BeneficiosFidelidad SET
                    Nombre             = @nombre,
                    Descripcion        = @desc,
                    ReservasRequeridas = @reservas,
                    IDTipoDescuento    = @tipo,
                    ValorDescuento     = @valor,
                    DiasValidez        = @dias
                WHERE IDBeneficio = @id");
            CargarParametros(datos, b);
            datos.AgregarParametro("@id", b.IdBeneficio);
            datos.EjecutarAccion();
        }

        public void BajaLogica(int idBeneficio)
        {
            AccesoDatos datos = new AccesoDatos();

            datos.SetearConsulta("UPDATE BeneficiosFidelidad SET Activo = 0 WHERE IDBeneficio = @id");
            datos.AgregarParametro("@id", idBeneficio);
            datos.EjecutarAccion();
        }

        public void Reactivar(int idBeneficio)
        {
            AccesoDatos datos = new AccesoDatos();

            datos.SetearConsulta("UPDATE BeneficiosFidelidad SET Activo = 1 WHERE IDBeneficio = @id");
            datos.AgregarParametro("@id", idBeneficio);
            datos.EjecutarAccion();
        }

        // Mapeo columna -> propiedad compartido por las tres lecturas.
        private BeneficioFidelidad Mapear(AccesoDatos datos)
        {
            BeneficioFidelidad b = new BeneficioFidelidad();
            b.IdBeneficio = (int)datos.Lector["IDBeneficio"];
            b.Nombre = (string)datos.Lector["Nombre"];
            b.Descripcion = datos.Lector["Descripcion"] is DBNull ? "" : (string)datos.Lector["Descripcion"];
            b.ReservasRequeridas = (int)datos.Lector["ReservasRequeridas"];
            b.TipoDescuento = (TipoDescuento)(int)datos.Lector["IDTipoDescuento"];
            b.ValorDescuento = datos.Lector["ValorDescuento"] is DBNull ? (decimal?)null : (decimal)datos.Lector["ValorDescuento"];
            b.DiasValidez = datos.Lector["DiasValidez"] is DBNull ? (int?)null : (int)datos.Lector["DiasValidez"];
            b.Activo = (bool)datos.Lector["Activo"];
            return b;
        }

        // Parámetros compartidos por Agregar y Modificar (los nullables van como DBNull).
        private void CargarParametros(AccesoDatos datos, BeneficioFidelidad b)
        {
            datos.AgregarParametro("@nombre", b.Nombre);
            datos.AgregarParametro("@desc", b.Descripcion ?? "");
            datos.AgregarParametro("@reservas", b.ReservasRequeridas);
            datos.AgregarParametro("@tipo", (int)b.TipoDescuento);
            datos.AgregarParametro("@valor", (object)b.ValorDescuento ?? DBNull.Value);
            datos.AgregarParametro("@dias", (object)b.DiasValidez ?? DBNull.Value);
        }
    }
}
