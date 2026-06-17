using System;
using System.Collections.Generic;
using Dominio;

namespace Negocio
{
    public class NegocioDeportes
    {
        // Devuelve TODOS (activos e inactivos) para poder reactivar los dados de baja.
        public List<Deporte> ObtenerTodas()
        {
            List<Deporte> lista = new List<Deporte>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.SetearConsulta("SELECT IDDeporte, Nombre, DuracionMinutos, Activa FROM Deportes ORDER BY Nombre");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    lista.Add(new Deporte
                    {
                        IdDeporte       = (int)datos.Lector["IDDeporte"],
                        Nombre          = (string)datos.Lector["Nombre"],
                        DuracionMinutos = (int)datos.Lector["DuracionMinutos"],
                        Activa          = (bool)datos.Lector["Activa"]
                    });
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

        public Deporte ObtenerPorId(int idDeporte)
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.SetearConsulta("SELECT IDDeporte, Nombre, DuracionMinutos, Activa FROM Deportes WHERE IDDeporte = @id");
                datos.AgregarParametro("@id", idDeporte);
                datos.EjecutarLectura();

                if (datos.Lector.Read())
                {
                    return new Deporte
                    {
                        IdDeporte       = (int)datos.Lector["IDDeporte"],
                        Nombre          = (string)datos.Lector["Nombre"],
                        DuracionMinutos = (int)datos.Lector["DuracionMinutos"],
                        Activa          = (bool)datos.Lector["Activa"]
                    };
                }
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

        public void Agregar(Deporte d)
        {
            AccesoDatos datos = new AccesoDatos();

            datos.SetearConsulta(@"
                INSERT INTO Deportes (Nombre, DuracionMinutos, Activa)
                VALUES (@nombre, @duracion, 1)");
            datos.AgregarParametro("@nombre", d.Nombre);
            datos.AgregarParametro("@duracion", d.DuracionMinutos);
            datos.EjecutarAccion();
        }

        public void Modificar(Deporte d)
        {
            AccesoDatos datos = new AccesoDatos();

            datos.SetearConsulta(@"
                UPDATE Deportes SET
                    Nombre          = @nombre,
                    DuracionMinutos = @duracion
                WHERE IDDeporte = @id");
            datos.AgregarParametro("@nombre", d.Nombre);
            datos.AgregarParametro("@duracion", d.DuracionMinutos);
            datos.AgregarParametro("@id", d.IdDeporte);
            datos.EjecutarAccion();
        }

        public void BajaLogica(int idDeporte)
        {
            AccesoDatos datos = new AccesoDatos();

            datos.SetearConsulta(
                "UPDATE Deportes SET Activa = 0 WHERE IDDeporte = @id");
            datos.AgregarParametro("@id", idDeporte);
            datos.EjecutarAccion();
        }

        public void Reactivar(int idDeporte)
        {
            AccesoDatos datos = new AccesoDatos();

            datos.SetearConsulta(
                "UPDATE Deportes SET Activa = 1 WHERE IDDeporte = @id");
            datos.AgregarParametro("@id", idDeporte);
            datos.EjecutarAccion();
        }
    }
}
