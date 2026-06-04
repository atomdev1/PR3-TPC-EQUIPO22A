using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dominio;


namespace Negocio
{
    public class NegocioCanchas
    {
        public List<Cancha> ObtenerTodas()
        {
            List<Cancha> lista = new List<Cancha>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.SetearConsulta(@"
                    SELECT c.IDCancha, c.Numero, c.NombreFantasia, c.Descripcion,
                           c.CapacidadJugadores, c.Precio, c.MontoSena, c.Activa,
                           c.IDDeporte, d.Nombre AS NombreDeporte, d.DuracionMinutos
                    FROM Canchas c
                    INNER JOIN Deportes d ON d.IDDeporte = c.IDDeporte");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    Cancha c = new Cancha();
                    c.IdCancha = (int)datos.Lector["IDCancha"];
                    c.Numero = (int)datos.Lector["Numero"];
                    c.NombreFantasia = (string)datos.Lector["NombreFantasia"];
                    c.Descripcion = datos.Lector["Descripcion"] is System.DBNull ? "" : (string)datos.Lector["Descripcion"];
                    c.CapacidadJugadores = (int)datos.Lector["CapacidadJugadores"];
                    c.Precio = (decimal)datos.Lector["Precio"];
                    c.MontoSena = (decimal)datos.Lector["MontoSena"];
                    c.Activa = (bool)datos.Lector["Activa"];
                    c.IdDeporte = (int)datos.Lector["IDDeporte"];
                    c.Deporte = new Deporte
                    {
                        IdDeporte = (int)datos.Lector["IDDeporte"],
                        Nombre = (string)datos.Lector["NombreDeporte"],
                        DuracionMinutos = (int)datos.Lector["DuracionMinutos"]
                    };
                    lista.Add(c);
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

        public List<Deporte> ObtenerDeportes()
        {
            List<Deporte> lista = new List<Deporte>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.SetearConsulta("SELECT IDDeporte, Nombre, DuracionMinutos FROM Deportes");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    lista.Add(new Deporte
                    {
                        IdDeporte = (int)datos.Lector["IDDeporte"],
                        Nombre = (string)datos.Lector["Nombre"],
                        DuracionMinutos = (int)datos.Lector["DuracionMinutos"]
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

        public void Agregar(Cancha c)
        {
            AccesoDatos datos = new AccesoDatos();
            
            datos.SetearConsulta(@"
                INSERT INTO Canchas
                    (Numero, NombreFantasia, Descripcion, CapacidadJugadores,
                     Precio, MontoSena, Activa, IDDeporte)
                VALUES
                    (@num, @nombre, @desc, @cap, @precio, @sena, 1, @dep)");
            datos.AgregarParametro("@num", c.Numero);
            datos.AgregarParametro("@nombre", c.NombreFantasia);
            datos.AgregarParametro("@desc", c.Descripcion ?? "");
            datos.AgregarParametro("@cap", c.CapacidadJugadores);
            datos.AgregarParametro("@precio", c.Precio);
            datos.AgregarParametro("@sena", c.MontoSena);
            datos.AgregarParametro("@dep", c.IdDeporte);
            datos.EjecutarAccion();
        }

        public void BajaLogica(int idCancha)
        {
            AccesoDatos datos = new AccesoDatos();

            datos.SetearConsulta(
                "UPDATE Canchas SET Activa = 0 WHERE IDCancha = @id");
            datos.AgregarParametro("@id", idCancha);
            datos.EjecutarAccion();
        }
    }
}

