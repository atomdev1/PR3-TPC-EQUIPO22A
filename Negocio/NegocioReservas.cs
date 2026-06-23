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

        // Alimenta el mapa de calor del Panel. Lee la vista vw_OcupacionPorTurno,
        // que ya devuelve el dato agregado por dia de semana y turno.
        public List<OcupacionTurno> ObtenerOcupacionPorTurno()
        {
            List<OcupacionTurno> lista = new List<OcupacionTurno>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT DiaNum, Dia, TurnoOrden, Turno, CantidadReservas, PorcentajeOcupacion
                    FROM   vw_OcupacionPorTurno
                    ORDER BY DiaNum, TurnoOrden");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    OcupacionTurno o = new OcupacionTurno();
                    o.DiaNum = (int)datos.Lector["DiaNum"];
                    o.Dia = (string)datos.Lector["Dia"];
                    o.TurnoOrden = (int)datos.Lector["TurnoOrden"];
                    o.Turno = (string)datos.Lector["Turno"];
                    o.CantidadReservas = (int)datos.Lector["CantidadReservas"];
                    o.PorcentajeOcupacion = datos.Lector["PorcentajeOcupacion"] is DBNull
                                            ? 0m : (decimal)datos.Lector["PorcentajeOcupacion"];
                    lista.Add(o);
                }
                return lista;
            }
            finally { datos.CerrarConexion(); }
        }

        public List<CanchaMenorUso> ObtenerCanchasMenorUso()
        {
            List<CanchaMenorUso> lista = new List<CanchaMenorUso>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
            SELECT NroCancha, NombreFantasia, Deporte, ReservasXMes, Mes, Anio
            FROM   vw_CanchasMenorUso
            ORDER BY ReservasXMes ASC, NroCancha ASC");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    lista.Add(new CanchaMenorUso
                    {
                        NroCancha = (int)datos.Lector["NroCancha"],
                        NombreFantasia = datos.Lector["NombreFantasia"] is DBNull ? "" : (string)datos.Lector["NombreFantasia"],
                        Deporte = (string)datos.Lector["Deporte"],
                        ReservasXMes = (int)datos.Lector["ReservasXMes"],
                        Mes = (int)datos.Lector["Mes"],
                        Anio = (int)datos.Lector["Anio"]
                    });
                }
                return lista;
            }
            catch (Exception)
            {
                return new List<CanchaMenorUso>();
            }
            finally { datos.CerrarConexion(); }
        }

        public void Finalizar(int idReserva)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta("EXEC SP_FinalizarReserva @IDReserva = @id");
                datos.AgregarParametro("@id", idReserva);
                datos.EjecutarAccion();
            }
            finally { datos.CerrarConexion(); }
        }

        public void CancelarReserva(int idReserva)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearProcedimiento("sp_CancelarReserva");
                datos.AgregarParametro("@IDReserva", idReserva);
                datos.EjecutarAccion();
            }
            finally { datos.CerrarConexion(); }
        }

        public List<ClienteDeudor> ObtenerClientesDeudores()
        {
            List<ClienteDeudor> lista = new List<ClienteDeudor>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta("SELECT IDUsuario, DNI, Nombre, Apellido, Email, Telefono, ReservasConDeuda, MontoDeudaTotal FROM vw_ClientesDeudores ORDER BY MontoDeudaTotal DESC");
                datos.EjecutarLectura();
                while (datos.Lector.Read())
                {
                    ClienteDeudor c = new ClienteDeudor();
                    c.IdUsuario = (int)datos.Lector["IDUsuario"];
                    c.DNI = (string)datos.Lector["DNI"];
                    c.Nombre = (string)datos.Lector["Nombre"];
                    c.Apellido = (string)datos.Lector["Apellido"];
                    c.Email = (string)datos.Lector["Email"];
                    c.Telefono = datos.Lector["Telefono"] is DBNull ? "" : (string)datos.Lector["Telefono"];
                    c.ReservasConDeuda = (int)datos.Lector["ReservasConDeuda"];
                    c.MontoDeudaTotal = (decimal)datos.Lector["MontoDeudaTotal"];
                    lista.Add(c);
                }
                return lista;
            }
            finally { datos.CerrarConexion(); }
        }
    }
}
