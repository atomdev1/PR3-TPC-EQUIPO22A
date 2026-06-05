using System;
using System.Collections.Generic;
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
        public Usuario Cliente { get; set; }    // el que reserva la cancha
        public Usuario Staff { get; set; }      // el del mostrador que la carga
        public Cancha Cancha { get; set; }
        public Cupon Cupon { get; set; }        // puede no tener, queda null
        public EstadoReserva Estado { get; set; }
        public EstadoPago EstadoPago { get; set; }
        public List<Pago> Pagos { get; set; }   // una reserva junta varios pagos (la seña y despues el saldo)

        public Reserva()
        {
            // la arranco vacia asi nunca queda null cuando la recorro
            Pagos = new List<Pago>();
        }
    }
}
