using System;
using System.Collections.Generic;
using System.Linq;
using Dominio;
using Dominio.Enums;

namespace Negocio
{
    public class NegocioReservas
    {
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
                   ISNULL(p.TotalPagado, 0) AS TotalPagado,
                   u.IDUsuario  AS ClienteId,
                   u.Nombre     AS ClienteNombre,
                   u.Apellido   AS ClienteApellido,
                   c.IDCancha   AS CanchaId,
                   c.NombreFantasia AS CanchaNombre,
                   d.Nombre     AS DeporteNombre
            FROM   Reservas r
            INNER JOIN Usuarios u ON u.IDUsuario = r.IDUsuario_Cliente
            INNER JOIN Canchas  c ON c.IDCancha  = r.IDCancha
            INNER JOIN Deportes d ON d.IDDeporte = c.IDDeporte
            LEFT JOIN (
                SELECT IDReserva, SUM(Monto) AS TotalPagado
                FROM   Pagos
                GROUP BY IDReserva
            ) p ON p.IDReserva = r.IDReserva
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
                    r.TotalPagado = (decimal)datos.Lector["TotalPagado"];
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
                        IdCancha = (int)datos.Lector["CanchaId"],
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

        // Hay choque si en la misma cancha y fecha ya existe otra reserva no
        // cancelada cuyo horario se cruza con el pedido. El cruce de rangos es
        // HoraInicio < finPedido y HoraFin > inicioPedido. El idReservaExcluir
        // deja afuera a la propia reserva cuando se reprograma.
        public bool ExisteSolapamiento(int idCancha, DateTime fecha, TimeSpan horaInicio, TimeSpan horaFin, int idReservaExcluir = 0)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT COUNT(*)
                    FROM   Reservas
                    WHERE  IDCancha = @idCancha
                      AND  Fecha = @fecha
                      AND  IDEstado <> @cancelada
                      AND  IDReserva <> @excluir
                      AND  HoraInicio < @horaFin
                      AND  HoraFin > @horaInicio");
                datos.AgregarParametro("@idCancha", idCancha);
                datos.AgregarParametro("@fecha", fecha.Date);
                datos.AgregarParametro("@cancelada", (int)EstadoReserva.Cancelada);
                datos.AgregarParametro("@excluir", idReservaExcluir);
                datos.AgregarParametro("@horaInicio", horaInicio);
                datos.AgregarParametro("@horaFin", horaFin);
                return datos.EjecutarAccionScalar() > 0;
            }
            finally { datos.CerrarConexion(); }
        }

        // Turnos no cancelados de una cancha en una fecha. Solo traigo el rango
        // horario, alcanza para descartar los bloques ocupados. El idReservaExcluir
        // deja afuera a la propia reserva cuando se reprograma, asi su turno actual
        // no aparece ocupado por ella misma.
        public List<Reserva> ObtenerReservasDelDia(int idCancha, DateTime fecha, int idReservaExcluir = 0)
        {
            List<Reserva> lista = new List<Reserva>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT HoraInicio, HoraFin
                    FROM   Reservas
                    WHERE  IDCancha = @idCancha
                      AND  Fecha = @fecha
                      AND  IDEstado <> @cancelada
                      AND  IDReserva <> @excluir");
                datos.AgregarParametro("@idCancha", idCancha);
                datos.AgregarParametro("@fecha", fecha.Date);
                datos.AgregarParametro("@cancelada", (int)EstadoReserva.Cancelada);
                datos.AgregarParametro("@excluir", idReservaExcluir);
                datos.EjecutarLectura();
                while (datos.Lector.Read())
                {
                    lista.Add(new Reserva
                    {
                        HoraInicio = (TimeSpan)datos.Lector["HoraInicio"],
                        HoraFin = (TimeSpan)datos.Lector["HoraFin"]
                    });
                }
                return lista;
            }
            finally { datos.CerrarConexion(); }
        }

        // Turnos de 1 hora libres de una cancha para una fecha. Corta cada franja
        // de disponibilidad en bloques de una hora en horas exactas y descarta los
        // que ya tienen reserva. Si la fecha es hoy, deja afuera los que ya pasaron.
        // El idReservaExcluir se reenvia para que al reprogramar el turno propio
        // siga apareciendo como disponible.
        public List<TimeSpan> ObtenerHorariosDisponibles(int idCancha, DateTime fecha, List<DisponibilidadCancha> franjas, int idReservaExcluir = 0)
        {
            List<TimeSpan> disponibles = new List<TimeSpan>();
            if (franjas == null || franjas.Count == 0) return disponibles;

            List<Reserva> ocupadas = ObtenerReservasDelDia(idCancha, fecha, idReservaExcluir);
            TimeSpan unaHora = TimeSpan.FromHours(1);
            bool esHoy = fecha.Date == DateTime.Today;

            foreach (DisponibilidadCancha f in franjas)
            {
                for (TimeSpan inicio = f.HoraApertura; inicio + unaHora <= f.HoraCierre; inicio += unaHora)
                {
                    TimeSpan fin = inicio + unaHora;
                    if (esHoy && inicio <= DateTime.Now.TimeOfDay) continue;
                    bool pisa = ocupadas.Any(o => o.HoraInicio < fin && o.HoraFin > inicio);
                    if (!pisa) disponibles.Add(inicio);
                }
            }
            return disponibles;
        }

        // Alta real de una reserva. El estado arranca en Nueva y el de pago en
        // Pendiente: no se eligen desde la UI, los pone la capa. El estado de pago
        // despues lo sincroniza el trigger a medida que entran los pagos.
        public void Crear(Reserva r)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    INSERT INTO Reservas
                        (Fecha, HoraInicio, HoraFin, PrecioTotal, Observaciones,
                         IDUsuario_Cliente, IDUsuario_Staff, IDCancha, IDEstado, IDEstadoPago)
                    VALUES
                        (@fecha, @horaInicio, @horaFin, @precio, @observaciones,
                         @idCliente, @idStaff, @idCancha, @idEstado, @idEstadoPago)");
                datos.AgregarParametro("@fecha", r.Fecha.Date);
                datos.AgregarParametro("@horaInicio", r.HoraInicio);
                datos.AgregarParametro("@horaFin", r.HoraFin);
                datos.AgregarParametro("@precio", r.PrecioTotal);
                datos.AgregarParametro("@observaciones",
                    string.IsNullOrWhiteSpace(r.Observaciones) ? (object)DBNull.Value : r.Observaciones);
                datos.AgregarParametro("@idCliente", r.Cliente.IdUsuario);
                datos.AgregarParametro("@idStaff",
                    r.Staff != null ? (object)r.Staff.IdUsuario : DBNull.Value);
                datos.AgregarParametro("@idCancha", r.Cancha.IdCancha);
                datos.AgregarParametro("@idEstado", (int)EstadoReserva.Nueva);
                datos.AgregarParametro("@idEstadoPago", (int)EstadoPago.Pendiente);
                datos.EjecutarAccion();
            }
            finally { datos.CerrarConexion(); }
        }

        // Mueve una reserva a otra fecha/horario y la deja en estado Reprogramada.
        // No toca cancha, cliente ni precio. Reprogramar es correr el turno, no
        // rearmar la reserva. El solapamiento (excluyendo la propia) se controla
        // en la capa web antes de llamar a este metodo.
        public void Reprogramar(int idReserva, DateTime nuevaFecha, TimeSpan horaInicio, TimeSpan horaFin)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    UPDATE Reservas
                    SET    Fecha = @fecha,
                           HoraInicio = @horaInicio,
                           HoraFin = @horaFin,
                           IDEstado = @idEstado
                    WHERE  IDReserva = @idReserva");
                datos.AgregarParametro("@fecha", nuevaFecha.Date);
                datos.AgregarParametro("@horaInicio", horaInicio);
                datos.AgregarParametro("@horaFin", horaFin);
                datos.AgregarParametro("@idEstado", (int)EstadoReserva.Reprogramada);
                datos.AgregarParametro("@idReserva", idReserva);
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
