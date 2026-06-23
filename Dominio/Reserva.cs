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
        public decimal TotalPagado { get; set; }   // suma de los pagos de la reserva (lo trae Listar en una sola query)
        public string Observaciones { get; set; }

        // Lo que falta cobrar. Si por algún ajuste se pagó de más, no devuelvo negativo.
        public decimal SaldoPendiente
        {
            get
            {
                decimal saldo = PrecioTotal - TotalPagado;
                return saldo < 0 ? 0 : saldo;
            }
        }
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
