namespace Dominio.Enums
{
    // estos coinciden con los IDTipoDescuento de la tabla
    // ReservaGratis reemplaza la tabla TipoCupon que sacamos, es el cupon sin costo (no usa ValorDescuento)
    public enum TipoDescuento
    {
        Porcentaje = 1,
        ReservaGratis = 2
    }
}
