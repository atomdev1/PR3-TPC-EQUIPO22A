using System;
using Dominio.Enums;

namespace Dominio
{
    public class Reserva
    {
        public int IdReserva { get; set; }
        public DateTime Fecha { get; set; }
        public TimeSpan HoraInicio { get; set; }
        public TimeSpan HoraFin { get; set; }
        public decimal PrecioTotal { get; set; }
        public string Observaciones { get; set; }
        public int IdUsuarioCliente { get; set; }
        public int IdUsuarioStaff { get; set; }
        public int IdCancha { get; set; }
        public EstadoReservaEnum Estado { get; set; }
        public EstadoPago EstadoPago { get; set; }
        public int? IdCupon { get; set; } // Una reserva puede no tener cupon, asique la hacemos nullable
    }
}
