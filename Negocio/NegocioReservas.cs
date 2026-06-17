using System;
using System.Collections.Generic;
using Dominio;
using Dominio.Enums;

namespace Negocio
{
    public class NegocioReservas
    {
        // Pendiente de IMPLEMENTACIÓN — métodos CRUD para Reservas.aspx

        public List<Reserva> ObtenerPorMes(int año, int mes)
        {
            List<Reserva> lista = new List<Reserva>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT r.IDReserva, r.Fecha, r.HoraInicio, r.IDEstado,
                           u.Nombre   AS ClienteNombre,
                           u.Apellido AS ClienteApellido,
                           c.NombreFantasia AS CanchaNombre
                    FROM Reservas r
                    INNER JOIN Usuarios u ON u.IDUsuario = r.IDUsuario_Cliente
                    INNER JOIN Canchas  c ON c.IDCancha  = r.IDCancha
                    WHERE YEAR(r.Fecha) = @año AND MONTH(r.Fecha) = @mes
                    ORDER BY r.Fecha, r.HoraInicio");
                datos.AgregarParametro("@año", año);
                datos.AgregarParametro("@mes", mes);
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    Reserva r = new Reserva();
                    r.IdReserva  = (int)datos.Lector["IDReserva"];
                    r.Fecha      = (DateTime)datos.Lector["Fecha"];
                    r.HoraInicio = (TimeSpan)datos.Lector["HoraInicio"];
                    r.Estado     = (EstadoReserva)(int)datos.Lector["IDEstado"];
                    r.Cliente    = new Usuario
                    {
                        Nombre   = (string)datos.Lector["ClienteNombre"],
                        Apellido = (string)datos.Lector["ClienteApellido"]
                    };
                    r.Cancha = new Cancha { NombreFantasia = (string)datos.Lector["CanchaNombre"] };
                    lista.Add(r);
                }
                return lista;
            }
            catch (Exception)
            {
                // Si la tabla aún no tiene datos o la query falla, el calendario igual se muestra vacío
                return new List<Reserva>();
            }
            finally { datos.CerrarConexion(); }
        }

        public List<Reserva> Listar()
        {
            List<Reserva> lista = new List<Reserva>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
            SELECT r.IDReserva, r.Fecha, r.HoraInicio, r.HoraFin,
                   r.PrecioTotal, r.Observaciones,
                   r.IDEstado, r.IDEstadoPago,
                   u.IDUsuario  AS ClienteId,
                   u.Nombre     AS ClienteNombre,
                   u.Apellido   AS ClienteApellido,
                   c.NombreFantasia AS CanchaNombre,
                   d.Nombre     AS DeporteNombre
            FROM   Reservas r
            INNER JOIN Usuarios u ON u.IDUsuario = r.IDUsuario_Cliente
            INNER JOIN Canchas  c ON c.IDCancha  = r.IDCancha
            INNER JOIN Deportes d ON d.IDDeporte = c.IDDeporte
            ORDER BY r.Fecha DESC, r.HoraInicio DESC");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    Reserva r = new Reserva();
                    r.IdReserva = (int)datos.Lector["IDReserva"];
                    r.Fecha = (DateTime)datos.Lector["Fecha"];
                    r.HoraInicio = (TimeSpan)datos.Lector["HoraInicio"];
                    r.HoraFin = (TimeSpan)datos.Lector["HoraFin"];
                    r.PrecioTotal = (decimal)datos.Lector["PrecioTotal"];
                    r.Observaciones = datos.Lector["Observaciones"] is DBNull
                                      ? "" : (string)datos.Lector["Observaciones"];
                    r.Estado = (EstadoReserva)(int)datos.Lector["IDEstado"];
                    r.EstadoPago = (EstadoPago)(int)datos.Lector["IDEstadoPago"];
                    r.Cliente = new Usuario
                    {
                        IdUsuario = (int)datos.Lector["ClienteId"],
                        Nombre = (string)datos.Lector["ClienteNombre"],
                        Apellido = (string)datos.Lector["ClienteApellido"]
                    };
                    r.Cancha = new Cancha
                    {
                        NombreFantasia = (string)datos.Lector["CanchaNombre"],
                        Deporte = new Deporte { Nombre = (string)datos.Lector["DeporteNombre"] }
                    };
                    lista.Add(r);
                }
                return lista;
            }
            finally { datos.CerrarConexion(); }
        }
    }
}
