using Dominio;
using Dominio.Enums;
using Negocio;
using System;
using System.Collections.Generic;
using System.Linq;

namespace WebApp
{
    public partial class Reservas : System.Web.UI.Page
    {
        protected bool EsCliente { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            EsCliente = u.Rol == RolUsuario.Cliente;

            // El cliente no elige cliente (es el de la sesion) ni toca el precio
            // (lo fija la cancha). El mostrador si.
            pnlClienteNueva.Visible = !EsCliente;
            txtPrecioNueva.ReadOnly = EsCliente;
            if (EsCliente)
                lblAyudaPrecio.Text = "El precio lo fija la cancha.";

            if (!IsPostBack)
            {
                CargarCanchasFiltro();
                CargarCombosNuevaReserva();

                // Si llego desde el Calendario, dejo en los filtros lo que venga por la
                // URL (fecha + estado + cancha) antes de cargar, asi la grilla aparece
                // con el mismo filtro que tenia el calendario.
                PreseleccionarFiltros();
                CargarReservas(u);

                // Si vengo del Calendario clickeando una franja ocupada, abro el
                // detalle de esa reserva directamente.
                string verReserva = Request.QueryString["verReserva"];
                int idVer;
                if (!string.IsNullOrEmpty(verReserva) && int.TryParse(verReserva, out idVer))
                    MostrarDetalle(idVer);

                // El cliente llega desde el catalogo con la cancha ya elegida.
                // Abro el modal con esa cancha.
                if (EsCliente)
                    PreseleccionarCanchaCliente();
            }
        }

        // Combos del alta de reserva. El combo de cliente solo lo necesita el
        // mostrador, el de canchas lo usan los dos (mostrador y cliente).
        private void CargarCombosNuevaReserva()
        {
            if (!EsCliente)
            {
                ddlClienteNueva.Items.Clear();
                ddlClienteNueva.Items.Add(new System.Web.UI.WebControls.ListItem("-- Seleccioná un cliente --", "0"));
                foreach (Usuario c in new NegocioUsuarios().ObtenerClientes())
                    ddlClienteNueva.Items.Add(new System.Web.UI.WebControls.ListItem(c.Apellido + ", " + c.Nombre, c.IdUsuario.ToString()));
            }

            ddlCanchaNueva.DataSource = new NegocioCanchas().ObtenerTodas();
            ddlCanchaNueva.DataValueField = "IdCancha";
            ddlCanchaNueva.DataTextField = "NombreFantasia";
            ddlCanchaNueva.DataBind();
            ddlCanchaNueva.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Seleccioná una cancha --", "0"));
        }

        // Si la URL trae una cancha valida, la deja elegida con su precio, carga
        // los turnos libres y abre el modal solo para que el cliente reserve.
        private void PreseleccionarCanchaCliente()
        {
            string idCanchaTexto = Request.QueryString["cancha"];
            if (string.IsNullOrEmpty(idCanchaTexto)) return;
            if (ddlCanchaNueva.Items.FindByValue(idCanchaTexto) == null) return;

            ddlCanchaNueva.SelectedValue = idCanchaTexto;

            Cancha c = new NegocioCanchas().ObtenerPorId(int.Parse(idCanchaTexto));
            if (c != null) txtPrecioNueva.Text = c.Precio.ToString("0.##");

            CargarHorariosNueva();
            AbrirModalNuevaReserva();
        }

        // Drill-down desde el Calendario: dejo en los filtros lo que venga por la URL.
        // Los filtros que ya tiene CargarReservas hacen el resto. Las claves festado/
        // fcancha son propias del calendario para no chocar con el ?cancha= del alta.
        private void PreseleccionarFiltros()
        {
            string fechaTexto = Request.QueryString["fecha"];
            DateTime fecha;
            if (!string.IsNullOrEmpty(fechaTexto) && DateTime.TryParse(fechaTexto, out fecha))
                txtFiltroFecha.Text = fecha.ToString("yyyy-MM-dd");

            string estado = Request.QueryString["festado"];
            if (!string.IsNullOrEmpty(estado) && ddlFiltroEstado.Items.FindByValue(estado) != null)
                ddlFiltroEstado.SelectedValue = estado;

            string cancha = Request.QueryString["fcancha"];
            if (!string.IsNullOrEmpty(cancha) && ddlFiltroCancha.Items.FindByValue(cancha) != null)
                ddlFiltroCancha.SelectedValue = cancha;
        }

        // Llena el combo de canchas del filtro con datos de la BD.
        private void CargarCanchasFiltro()
        {
            ddlFiltroCancha.DataSource = new NegocioCanchas().ObtenerTodas();
            ddlFiltroCancha.DataValueField = "IdCancha";
            ddlFiltroCancha.DataTextField = "NombreFantasia";
            ddlFiltroCancha.DataBind();
            ddlFiltroCancha.Items.Insert(0, new System.Web.UI.WebControls.ListItem("Todas las canchas", "0"));
        }

        private void CargarReservas(Usuario u)
        {
            List<Reserva> lista = new NegocioReservas().Listar();

            if (u.Rol == RolUsuario.Cliente)
                lista = lista.Where(r => r.Cliente.IdUsuario == u.IdUsuario).ToList();

            // Filtros (todos opcionales): estado, cancha y fecha.
            if (ddlFiltroEstado.SelectedValue != "0")
            {
                int idEstado = int.Parse(ddlFiltroEstado.SelectedValue);
                lista = lista.Where(r => (int)r.Estado == idEstado).ToList();
            }

            if (ddlFiltroCancha.SelectedValue != "0")
            {
                string cancha = ddlFiltroCancha.SelectedItem.Text;
                lista = lista.Where(r => r.Cancha.NombreFantasia == cancha).ToList();
            }

            DateTime fecha;
            if (DateTime.TryParse(txtFiltroFecha.Text, out fecha))
                lista = lista.Where(r => r.Fecha.Date == fecha.Date).ToList();

            rptReservas.DataSource = lista;
            rptReservas.DataBind();

            lblTotal.Text = lista.Count == 1
                ? "1 reserva"
                : lista.Count + " reservas";
        }

        protected void btnFiltrar_Click(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }
            CargarReservas(u);
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            ddlFiltroEstado.SelectedValue = "0";
            ddlFiltroCancha.SelectedValue = "0";
            txtFiltroFecha.Text = "";
            CargarReservas(u);
        }

        // Botones de fila de la grilla. Por ahora solo implemento "RegistrarPago", que abre
        // el modal cargado con el saldo de la reserva.
        protected void rptReservas_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Ver")
            {
                MostrarDetalle(int.Parse(e.CommandArgument.ToString()));
            }
            else if (e.CommandName == "RegistrarPago")
            {
                int idReserva = int.Parse(e.CommandArgument.ToString());

                // Precio total y lo ya pagado ya vienen en la reserva (Listar los
                // trae en una sola query), así que el saldo sale sin viajar de nuevo.
                Reserva reserva = new NegocioReservas().Listar()
                    .FirstOrDefault(r => r.IdReserva == idReserva);
                if (reserva == null) return;

                decimal saldo = reserva.SaldoPendiente;

                hfIdReservaPago.Value = idReserva.ToString();
                lblPagoReserva.Text   = "Reserva #" + idReserva;
                lblPagoPrecio.Text    = string.Format("{0:C0}", reserva.PrecioTotal);
                lblPagoPagado.Text    = string.Format("{0:C0}", reserva.TotalPagado);
                lblPagoSaldo.Text     = string.Format("{0:C0}", saldo);
                txtMontoPago.Text     = saldo.ToString("0.##");
                ddlFormaPago.SelectedValue = "1";
                lblErrorPago.Visible  = false;

                AbrirModalPago();
            }
            else if (e.CommandName == "VerPagos")
            {
                int idReserva = int.Parse(e.CommandArgument.ToString());
                Reserva reserva = new NegocioReservas().Listar()
                    .FirstOrDefault(r => r.IdReserva == idReserva);
                if (reserva == null) return;

                List<Pago> pagos = new NegocioPagos().ObtenerPagosPorReserva(idReserva);

                lblPagosReserva.Text = "Reserva #" + idReserva;
                lblPagosPrecio.Text  = string.Format("{0:C0}", reserva.PrecioTotal);
                lblPagosPagado.Text  = string.Format("{0:C0}", reserva.TotalPagado);
                lblPagosSaldo.Text   = string.Format("{0:C0}", reserva.SaldoPendiente);

                rptPagos.DataSource = pagos;
                rptPagos.DataBind();
                lblPagosVacio.Visible = pagos.Count == 0;

                AbrirModalDetallePago();
            }
            else if (e.CommandName == "Canjear")
            {
                int idReserva = int.Parse(e.CommandArgument.ToString());

                Reserva reserva = new NegocioReservas().Listar()
                    .FirstOrDefault(r => r.IdReserva == idReserva);
                if (reserva == null) return;

                hfIdReservaCanje.Value = idReserva.ToString();
                lblCanjeReserva.Text   = "Reserva #" + idReserva;
                lblCanjePrecio.Text    = string.Format("{0:C0}", reserva.PrecioTotal);
                txtCodigoCupon.Text    = "";
                lblErrorCanje.Visible  = false;

                AbrirModalCanje();
            }
            else if (e.CommandName == "PagarOnline")
            {
                int idReserva = int.Parse(e.CommandArgument.ToString());
                Reserva reserva = new NegocioReservas().Listar()
                    .FirstOrDefault(r => r.IdReserva == idReserva);
                if (reserva == null) return;

                hfIdReservaOnline.Value = idReserva.ToString();
                lblOnlineReserva.Text   = "Reserva #" + idReserva;
                lblOnlinePrecio.Text    = string.Format("{0:C0}", reserva.PrecioTotal);
                lblOnlinePagado.Text    = string.Format("{0:C0}", reserva.TotalPagado);
                lblOnlineSaldo.Text     = string.Format("{0:C0}", reserva.SaldoPendiente);
                txtMontoOnline.Text     = reserva.SaldoPendiente.ToString("0.##");
                ddlMetodoOnline.SelectedValue = "4";
                txtTitular.Text       = "";
                txtNumeroTarjeta.Text = "";
                txtVencimiento.Text   = "";
                txtCvv.Text           = "";
                lblErrorOnline.Visible = false;
                pnlFormularioOnline.Visible = true;
                pnlExitoOnline.Visible = false;
                btnConfirmarPagoOnline.Visible = true;
                AplicarMetodoPagoOnline();

                AbrirModalPagoOnline();
            }
            else if (e.CommandName == "Cancelar")
            {
                int idReserva = int.Parse(e.CommandArgument.ToString());
                Reserva reserva = new NegocioReservas().Listar()
                    .FirstOrDefault(r => r.IdReserva == idReserva);
                if (reserva == null) return;

                hfIdReservaCancelacion.Value = idReserva.ToString();
                lblCancelacionReserva.Text = "Reserva #" + idReserva;
                lblCancelacionCliente.Text = reserva.Cliente.Nombre + " " + reserva.Cliente.Apellido;
                lblCancelacionFecha.Text = reserva.Fecha.ToString("dd/MM/yyyy") + " " +
                                               reserva.HoraInicio.ToString(@"hh\:mm") + " – " +
                                               reserva.HoraFin.ToString(@"hh\:mm");
                lblCancelacionPrecio.Text = string.Format("{0:C0}", reserva.PrecioTotal);
                lblErrorCancelacion.Visible = false;

                AbrirModalCancelacion();
            }
            else if (e.CommandName == "Reprogramar")
            {
                int idReserva = int.Parse(e.CommandArgument.ToString());
                Reserva reserva = new NegocioReservas().Listar()
                    .FirstOrDefault(r => r.IdReserva == idReserva);
                if (reserva == null) return;

                hfIdReservaReprogramar.Value = idReserva.ToString();
                hfIdCanchaReprogramar.Value = reserva.Cancha.IdCancha.ToString();
                lblReprogramarReserva.Text = "Reserva #" + idReserva;
                lblReprogramarCliente.Text = reserva.Cliente.Nombre + " " + reserva.Cliente.Apellido;
                lblReprogramarCancha.Text = reserva.Cancha.NombreFantasia + " · " + reserva.Cancha.Deporte.Nombre;
                lblReprogramarActual.Text = reserva.Fecha.ToString("dd/MM/yyyy") + " " +
                                            reserva.HoraInicio.ToString(@"hh\:mm") + " – " +
                                            reserva.HoraFin.ToString(@"hh\:mm");
                lblErrorReprogramar.Visible = false;

                // Arranco precargado con el turno actual. Misma fecha y horario,
                // que aparece disponible porque excluyo la propia reserva.
                txtFechaReprogramar.Text = reserva.Fecha.ToString("yyyy-MM-dd");
                CargarHorariosReprogramar();
                string actual = reserva.HoraInicio.ToString(@"hh\:mm");
                if (ddlHorarioReprogramar.Items.FindByValue(actual) != null)
                    ddlHorarioReprogramar.SelectedValue = actual;

                AbrirModalReprogramar();
            }
            else if (e.CommandName == "Finalizar")
            {
                int idReserva = int.Parse(e.CommandArgument.ToString());
                Reserva reserva = new NegocioReservas().Listar()
                    .FirstOrDefault(r => r.IdReserva == idReserva);
                if (reserva == null) return;

                hfIdReservaFinalizar.Value = idReserva.ToString();
                hfIdClienteFinalizar.Value = reserva.Cliente.IdUsuario.ToString();
                lblFinalizarReserva.Text = "Reserva #" + idReserva;
                lblFinalizarCliente.Text = reserva.Cliente.Nombre + " " + reserva.Cliente.Apellido;
                lblFinalizarFecha.Text = reserva.Fecha.ToString("dd/MM/yyyy") + " " +
                                         reserva.HoraInicio.ToString(@"hh\:mm") + " – " +
                                         reserva.HoraFin.ToString(@"hh\:mm");
                lblFinalizarPrecio.Text = string.Format("{0:C0}", reserva.PrecioTotal);
                lblErrorFinalizar.Visible = false;

                AbrirModalFinalizar();
            }
        }

        // Confirma la finalizacion. Si el SP la rechaza (ej pago pendiente), el
        // mensaje llega como excepcion y se muestra dentro del modal.
        protected void btnConfirmarFinalizar_Click(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            int idReserva = int.Parse(hfIdReservaFinalizar.Value);
            int idCliente = int.Parse(hfIdClienteFinalizar.Value);
            NegocioCupones negCupones = new NegocioCupones();
            pnlCuponGanado.Visible = false;

            try
            {
                // Cuento los cupones del cliente antes y despues: si al sumar la
                // asistencia el trigger TR_EmitirCuponFidelidad emite un cupon, el
                // total aumenta. Asi detecto la emision sin acoplarme al trigger.
                int cuponesAntes = negCupones.ContarPorUsuario(idCliente);
                new NegocioReservas().Finalizar(idReserva);
                int cuponesDespues = negCupones.ContarPorUsuario(idCliente);

                if (cuponesDespues > cuponesAntes)
                    MostrarCuponGanado(negCupones, idCliente);
            }
            catch (Exception ex)
            {
                lblErrorFinalizar.Text = ex.Message;
                lblErrorFinalizar.Visible = true;
                AbrirModalFinalizar();
                return;
            }

            CargarReservas(u);
        }

        // Arma el aviso con el cupon de fidelidad recien emitido. El mas nuevo con
        // codigo 'FID-' entre los cupones vigentes del cliente. El nombre del cliente
        // ya quedo cargado en el modal al abrirlo.
        private void MostrarCuponGanado(NegocioCupones negCupones, int idCliente)
        {
            Cupon nuevo = negCupones.ObtenerPorUsuario(idCliente)
                .Where(c => (c.Codigo ?? "").StartsWith("FID-"))
                .OrderByDescending(c => c.IdCupon)
                .FirstOrDefault();

            string cliente = Server.HtmlEncode(lblFinalizarCliente.Text);
            if (nuevo != null)
                lblCuponGanado.Text = string.Format(
                    "¡{0} sumó una asistencia y ganó un cupón de fidelidad: <strong>{1}</strong> (código {2})!",
                    cliente, Server.HtmlEncode(nuevo.Descripcion), Server.HtmlEncode(nuevo.Codigo));
            else
                lblCuponGanado.Text = string.Format(
                    "¡{0} sumó una asistencia y ganó un cupón de fidelidad!", cliente);

            pnlCuponGanado.Visible = true;
        }

        private void AbrirModalFinalizar()
        {
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalFinalizarReserva')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalFinalizar", script, true);
        }

        // Confirma el canje. Si el SP rechaza por una regla, hace THROW: el
        // mensaje llega como excepción y lo mostramos en el modal.
        protected void btnConfirmarCanje_Click(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            string codigo = txtCodigoCupon.Text.Trim();
            if (string.IsNullOrEmpty(codigo))
            {
                lblErrorCanje.Text = "Ingresá el código del cupón.";
                lblErrorCanje.Visible = true;
                AbrirModalCanje();
                return;
            }

            try
            {
                new NegocioCupones().Canjear(int.Parse(hfIdReservaCanje.Value), codigo);
            }
            catch (Exception ex)
            {
                // ex.Message trae el mensaje del THROW del SP.
                lblErrorCanje.Text = ex.Message;
                lblErrorCanje.Visible = true;
                AbrirModalCanje();
                return;
            }

            // Canje OK: recargo la grilla, el precio ya viene recalculado.
            CargarReservas(u);
        }

        // Confirma el pago: inserta en Pagos y el trigger recalcula el estado.
        protected void btnConfirmarPago_Click(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            decimal monto;
            if (!decimal.TryParse(txtMontoPago.Text, out monto) || monto <= 0)
            {
                lblErrorPago.Text = "Ingresá un monto válido mayor a cero.";
                lblErrorPago.Visible = true;
                AbrirModalPago();
                return;
            }

            Pago pago = new Pago
            {
                Monto = monto,
                FormaDePago = (FormaPago)int.Parse(ddlFormaPago.SelectedValue)
            };

            try
            {
                new NegocioPagos().RegistrarPago(pago, int.Parse(hfIdReservaPago.Value));
            }
            catch (Exception ex)
            {
                // Mensaje del guard de negocio o del THROW de la base (sobrepago).
                lblErrorPago.Text = ex.Message;
                lblErrorPago.Visible = true;
                AbrirModalPago();
                return;
            }

            // Recargo la grilla: el badge de pago ya viene actualizado por el trigger.
            CargarReservas(u);
        }

        // Corre por AutoPostBack dentro del UpdatePanel, así el
        // modal no se cierra al alternar tarjeta / MP.
        protected void ddlMetodoOnline_SelectedIndexChanged(object sender, EventArgs e)
        {
            AplicarMetodoPagoOnline();
        }

        // Muestra el panel de tarjeta o el de MP según el método. Si oculto el de
        // tarjeta, sus validadores no exigen nada.
        private void AplicarMetodoPagoOnline()
        {
            bool esTarjeta = ddlMetodoOnline.SelectedValue != "5";
            pnlTarjetaOnline.Visible = esTarjeta;
            pnlMercadoPagoOnline.Visible = !esTarjeta;
        }

        // Pago online del cliente: el mismo RegistrarPago del mostrador, solo que
        // acá simulo la tarjeta o Mercado Pago. Los datos de tarjeta no se guardan.
        protected void btnConfirmarPagoOnline_Click(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            // Requeridos y formato de tarjeta ya los cubren los validadores del modal.
            if (!Page.IsValid) return;

            decimal monto;
            if (!decimal.TryParse(txtMontoOnline.Text, out monto) || monto <= 0)
            {
                MostrarErrorOnline("Ingresá un monto válido mayor a cero.");
                return;
            }

            FormaPago forma = (FormaPago)int.Parse(ddlMetodoOnline.SelectedValue);

            // Lo que el validador no cubre: que la tarjeta no esté vencida.
            if (forma == FormaPago.TarjetaDebito || forma == FormaPago.TarjetaCredito)
            {
                if (TarjetaVencida(txtVencimiento.Text))
                {
                    MostrarErrorOnline("La tarjeta está vencida.");
                    return;
                }
            }

            int idReserva = int.Parse(hfIdReservaOnline.Value);
            Pago pago = new Pago { Monto = monto, FormaDePago = forma };

            try
            {
                new NegocioPagos().RegistrarPago(pago, idReserva);
            }
            catch (Exception ex)
            {
                MostrarErrorOnline(ex.Message);
                return;
            }

            // Pago OK: borro los datos sensibles, recargo la grilla y muestro el éxito.
            txtNumeroTarjeta.Text = "";
            txtCvv.Text = "";
            CargarReservas(u);

            Reserva actualizada = new NegocioReservas().Listar()
                .FirstOrDefault(r => r.IdReserva == idReserva);
            MostrarExitoOnline(monto, forma, actualizada);
        }

        // Paso el modal a modo éxito: oculto el formulario y muestro cómo quedó el pago.
        private void MostrarExitoOnline(decimal monto, FormaPago forma, Reserva reserva)
        {
            string metodo = GetTextoFormaPago(forma).ToLower();
            if (reserva != null)
                lblExitoOnline.Text = string.Format(
                    "Pagaste {0:C0} con {1}.<br />Saldo restante: <strong>{2:C0}</strong> · estado de pago: <strong>{3}</strong>.",
                    monto, metodo, reserva.SaldoPendiente, GetTextoPago(reserva.EstadoPago));
            else
                lblExitoOnline.Text = string.Format("Pagaste {0:C0} con {1}.", monto, metodo);

            pnlFormularioOnline.Visible = false;
            pnlExitoOnline.Visible = true;
            btnConfirmarPagoOnline.Visible = false;
            AbrirModalPagoOnline();
        }

        // El formato MM/AA ya viene validado: acá solo reviso que no haya pasado.
        private bool TarjetaVencida(string vencimiento)
        {
            string[] partes = vencimiento.Trim().Split('/');
            int mes  = int.Parse(partes[0]);
            int anio = 2000 + int.Parse(partes[1]);
            DateTime vence = new DateTime(anio, mes, 1).AddMonths(1).AddDays(-1);
            return vence < DateTime.Today;
        }

        private void MostrarErrorOnline(string mensaje)
        {
            lblErrorOnline.Text = mensaje;
            lblErrorOnline.Visible = true;
            AbrirModalPagoOnline();
        }

        private void AbrirModalPagoOnline()
        {
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalPagoOnline')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalPagoOnline", script, true);
        }

        private void AbrirModalPago()
        {
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalRegistrarPago')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalPago", script, true);
        }

        // Arma y abre el modal de detalle de una reserva. Lo usan el boton "Ver" de la
        // grilla y el drill-down del Calendario (?verReserva=). Antes esto vivia dentro
        // del comando "Ver". Lo saque a un metodo para no duplicarlo.
        private void MostrarDetalle(int idReserva)
        {
            Reserva r = new NegocioReservas().Listar()
                .FirstOrDefault(x => x.IdReserva == idReserva);
            if (r == null) return;

            lblDetCliente.Text = r.Cliente.Nombre + " " + r.Cliente.Apellido;
            lblDetCancha.Text  = r.Cancha.NombreFantasia + " · " + r.Cancha.Deporte.Nombre;
            lblDetFecha.Text   = r.Fecha.ToString("dd/MM/yyyy");
            lblDetHorario.Text = r.HoraInicio.ToString(@"hh\:mm") + " – " + r.HoraFin.ToString(@"hh\:mm");
            lblDetPrecio.Text  = string.Format("{0:C0}", r.PrecioTotal);
            lblDetEstado.Text  = r.Estado.ToString();
            lblDetPago.Text    = GetTextoPago(r.EstadoPago);
            lblDetPagado.Text  = string.Format("{0:C0}", r.TotalPagado);
            lblDetSaldo.Text   = string.Format("{0:C0}", r.SaldoPendiente);
            lblDetObs.Text     = string.IsNullOrEmpty(r.Observaciones) ? "Sin observaciones" : r.Observaciones;

            AbrirModalDetalle();
        }

        private void AbrirModalDetalle()
        {
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalDetalleReserva')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalDetalle", script, true);
        }

        private void AbrirModalDetallePago()
        {
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalDetallePago')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalDetallePago", script, true);
        }

        // Nombre legible de la forma de pago (los del enum no llevan acentos ni espacios).
        protected string GetTextoFormaPago(object formaObj)
        {
            FormaPago forma = (FormaPago)formaObj;
            switch (forma)
            {
                case FormaPago.TarjetaDebito:  return "Tarjeta de débito";
                case FormaPago.TarjetaCredito: return "Tarjeta de crédito";
                case FormaPago.MercadoPago:    return "Mercado Pago";
                default:                       return forma.ToString();
            }
        }

        private void AbrirModalCanje()
        {
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalCanjearCupon')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalCanje", script, true);
        }

        protected void btnConfirmarCancelacion_Click(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            try
            {
                new NegocioReservas().CancelarReserva(int.Parse(hfIdReservaCancelacion.Value));
            }
            catch (Exception ex)
            {
                lblErrorCancelacion.Text = ex.Message;
                lblErrorCancelacion.Visible = true;
                AbrirModalCancelacion();
                return;
            }

            CargarReservas(u);
        }

        private void AbrirModalCancelacion()
        {
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalCancelarReserva')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalCancelacion", script, true);
        }

        // Cambiar la fecha recalcula los turnos libres de la misma cancha. Corre
        // por AutoPostBack dentro del UpdatePanel, asi el modal no se cierra.
        protected void txtFechaReprogramar_TextChanged(object sender, EventArgs e)
        {
            CargarHorariosReprogramar();
        }

        // Turnos de 1 hora libres para reprogramar. Cancha fija (la de la reserva),
        // fecha del propio modal, y excluyo la reserva que estoy moviendo para que
        // su turno actual no figure ocupado por ella misma.
        private void CargarHorariosReprogramar()
        {
            ddlHorarioReprogramar.Items.Clear();

            DateTime fecha;
            bool fechaOk = DateTime.TryParse(txtFechaReprogramar.Text, out fecha);
            int idCancha = int.Parse(hfIdCanchaReprogramar.Value);
            int idReserva = int.Parse(hfIdReservaReprogramar.Value);

            if (!fechaOk)
            {
                lblSinHorariosReprog.Text = "Elegí una fecha para ver los turnos disponibles.";
                lblSinHorariosReprog.Visible = true;
                ddlHorarioReprogramar.Visible = false;
                return;
            }

            // El enum DiaSemana va Lunes=0..Domingo=6. DateTime.DayOfWeek
            // arranca en Domingo=0, asi que lo corro para que coincidan.
            int diaBd = ((int)fecha.DayOfWeek + 6) % 7;
            List<DisponibilidadCancha> franjas = new NegocioCanchas().ObtenerDisponibilidades(idCancha, diaBd);
            List<TimeSpan> disponibles = new NegocioReservas().ObtenerHorariosDisponibles(idCancha, fecha, franjas, idReserva);

            if (disponibles.Count == 0)
            {
                lblSinHorariosReprog.Text = "No hay turnos disponibles para esa cancha en esa fecha.";
                lblSinHorariosReprog.Visible = true;
                ddlHorarioReprogramar.Visible = false;
                return;
            }

            lblSinHorariosReprog.Visible = false;
            ddlHorarioReprogramar.Visible = true;
            foreach (TimeSpan t in disponibles)
                ddlHorarioReprogramar.Items.Add(new System.Web.UI.WebControls.ListItem(FormatoTurno(t), t.ToString(@"hh\:mm")));
        }

        // Confirma la reprogramacion. Valida fecha futura y horario elegido, controla
        // el solapamiento excluyendo la propia reserva y recien ahi mueve el turno.
        protected void btnConfirmarReprogramar_Click(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            int idReserva = int.Parse(hfIdReservaReprogramar.Value);
            int idCancha = int.Parse(hfIdCanchaReprogramar.Value);

            DateTime fecha;
            if (!DateTime.TryParse(txtFechaReprogramar.Text, out fecha))
            {
                MostrarErrorReprogramar("Ingresá una fecha válida.");
                return;
            }
            if (fecha.Date < DateTime.Today)
            {
                MostrarErrorReprogramar("La fecha no puede ser anterior a hoy.");
                return;
            }

            TimeSpan horaInicio;
            if (ddlHorarioReprogramar.SelectedIndex < 0 || !TimeSpan.TryParse(ddlHorarioReprogramar.SelectedValue, out horaInicio))
            {
                MostrarErrorReprogramar("Elegí un horario disponible.");
                return;
            }
            TimeSpan horaFin = horaInicio + TimeSpan.FromHours(1);

            if (new NegocioReservas().ExisteSolapamiento(idCancha, fecha, horaInicio, horaFin, idReserva))
            {
                MostrarErrorReprogramar("Ya existe una reserva para esa cancha en ese horario.");
                return;
            }

            try
            {
                new NegocioReservas().Reprogramar(idReserva, fecha, horaInicio, horaFin);
            }
            catch (Exception ex)
            {
                MostrarErrorReprogramar(ex.Message);
                return;
            }

            CargarReservas(u);
        }

        private void MostrarErrorReprogramar(string mensaje)
        {
            lblErrorReprogramar.Text = mensaje;
            lblErrorReprogramar.Visible = true;
            AbrirModalReprogramar();
        }

        private void AbrirModalReprogramar()
        {
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalReprogramar')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalReprogramar", script, true);
        }

        // Al elegir la cancha sugiero su precio y recargo los turnos libres. Corre
        // por AutoPostBack dentro del UpdatePanel, asi el modal no se cierra.
        protected void ddlCanchaNueva_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlCanchaNueva.SelectedValue == "0")
                txtPrecioNueva.Text = "";
            else
            {
                Cancha c = new NegocioCanchas().ObtenerPorId(int.Parse(ddlCanchaNueva.SelectedValue));
                if (c != null) txtPrecioNueva.Text = c.Precio.ToString("0.##");
            }
            CargarHorariosNueva();
        }

        // Cambiar la fecha tambien recalcula los turnos libres.
        protected void txtFechaNueva_TextChanged(object sender, EventArgs e)
        {
            CargarHorariosNueva();
        }

        // Arma la lista de turnos de 1 hora libres para la cancha y fecha elegidas.
        // Llena el combo con todos y muestra los 3 primeros como atajo.
        private void CargarHorariosNueva()
        {
            ddlHorarioNueva.Items.Clear();
            rptSugeridos.DataSource = null;
            rptSugeridos.DataBind();
            pnlSugeridos.Visible = false;

            DateTime fecha;
            bool fechaOk = DateTime.TryParse(txtFechaNueva.Text, out fecha);
            bool canchaOk = ddlCanchaNueva.SelectedValue != "0";

            if (!fechaOk || !canchaOk)
            {
                lblSinHorarios.Text = "Elegí una cancha y una fecha para ver los turnos disponibles.";
                lblSinHorarios.Visible = true;
                ddlHorarioNueva.Visible = false;
                return;
            }

            int idCancha = int.Parse(ddlCanchaNueva.SelectedValue);
            // El enum DiaSemana va Lunes=0..Domingo=6 (ISO); DateTime.DayOfWeek
            // arranca en Domingo=0, asi que lo corro para que coincidan.
            int diaBd = ((int)fecha.DayOfWeek + 6) % 7;
            List<DisponibilidadCancha> franjas = new NegocioCanchas().ObtenerDisponibilidades(idCancha, diaBd);
            List<TimeSpan> disponibles = new NegocioReservas().ObtenerHorariosDisponibles(idCancha, fecha, franjas);

            if (disponibles.Count == 0)
            {
                lblSinHorarios.Text = "No hay turnos disponibles para esa cancha en esa fecha.";
                lblSinHorarios.Visible = true;
                ddlHorarioNueva.Visible = false;
                return;
            }

            lblSinHorarios.Visible = false;
            ddlHorarioNueva.Visible = true;
            foreach (TimeSpan t in disponibles)
                ddlHorarioNueva.Items.Add(new System.Web.UI.WebControls.ListItem(FormatoTurno(t), t.ToString(@"hh\:mm")));

            rptSugeridos.DataSource = disponibles.Take(3).ToList();
            rptSugeridos.DataBind();
            pnlSugeridos.Visible = true;
        }

        // Texto legible de un turno: "08:00 a 09:00". Lo usan el combo y los atajos.
        protected string FormatoTurno(object inicioObj)
        {
            TimeSpan inicio = (TimeSpan)inicioObj;
            TimeSpan fin = inicio + TimeSpan.FromHours(1);
            return inicio.ToString(@"hh\:mm") + " a " + fin.ToString(@"hh\:mm");
        }

        // Un atajo solo selecciona ese turno en el combo, que es la fuente unica.
        protected void rptSugeridos_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ElegirHorario") return;

            string valor = e.CommandArgument.ToString();
            if (ddlHorarioNueva.Items.FindByValue(valor) != null)
                ddlHorarioNueva.SelectedValue = valor;
        }

        // Alta real de la reserva. Valido todo en server antes de tocar la base y
        // freno el solapamiento de turnos. Si algo falla, reabro el modal con el error.
        protected void btnGuardarReserva_Click(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            // El cliente se reserva a si mismo, el mostrador elige al cliente.
            if (!EsCliente && ddlClienteNueva.SelectedValue == "0") { MostrarErrorNueva("Elegí un cliente."); return; }
            if (ddlCanchaNueva.SelectedValue == "0") { MostrarErrorNueva("Elegí una cancha."); return; }

            DateTime fecha;
            if (!DateTime.TryParse(txtFechaNueva.Text, out fecha))
            {
                MostrarErrorNueva("Ingresá una fecha válida.");
                return;
            }
            if (fecha.Date < DateTime.Today)
            {
                MostrarErrorNueva("La fecha no puede ser anterior a hoy.");
                return;
            }

            // El turno sale del combo de horarios libres. La reserva dura 1 hora.
            TimeSpan horaInicio;
            if (ddlHorarioNueva.SelectedIndex < 0 || !TimeSpan.TryParse(ddlHorarioNueva.SelectedValue, out horaInicio))
            {
                MostrarErrorNueva("Elegí un horario disponible.");
                return;
            }
            TimeSpan horaFin = horaInicio + TimeSpan.FromHours(1);

            int idCancha = int.Parse(ddlCanchaNueva.SelectedValue);

            // El cliente no fija el precio, lo toma de la cancha.
            // El mostrador si lo carga a mano.
            decimal precio;
            if (EsCliente)
            {
                Cancha cancha = new NegocioCanchas().ObtenerPorId(idCancha);
                if (cancha == null) { MostrarErrorNueva("La cancha elegida no existe."); return; }
                precio = cancha.Precio;
            }
            else if (!decimal.TryParse(txtPrecioNueva.Text, out precio) || precio <= 0)
            {
                MostrarErrorNueva("Ingresá un precio válido mayor a cero.");
                return;
            }

            string obs = txtObservacionesNueva.Text.Trim();
            if (obs.Length > 255)
            {
                MostrarErrorNueva("Las observaciones no pueden superar los 255 caracteres.");
                return;
            }

            if (new NegocioReservas().ExisteSolapamiento(idCancha, fecha, horaInicio, horaFin))
            {
                MostrarErrorNueva("Ya existe una reserva para esa cancha en ese horario.");
                return;
            }

            // Autogestion: el cliente es el de la sesion y no hay staff (Staff NULL).
            // Mostrador: el cliente sale del combo y el staff es el operador.
            Reserva r = new Reserva
            {
                Fecha = fecha,
                HoraInicio = horaInicio,
                HoraFin = horaFin,
                PrecioTotal = precio,
                Observaciones = obs,
                Cliente = EsCliente ? u : new Usuario { IdUsuario = int.Parse(ddlClienteNueva.SelectedValue) },
                Staff = EsCliente ? null : u,
                Cancha = new Cancha { IdCancha = idCancha }
            };

            int idNueva;
            try
            {
                idNueva = new NegocioReservas().Crear(r);
            }
            catch (Exception ex)
            {
                MostrarErrorNueva(ex.Message);
                return;
            }

            // Canje encadenado (no atómico): la reserva ya quedó creada. Si el
            // cliente cargó un cupon, lo aplico sobre la reserva recién creada.
            // Si el SP lo rechaza no perdemos la reserva, aviso el motivo y sigo
            // (la reserva fue efectiva).
            string codigoCupon = txtCuponNueva.Text.Trim();
            if (codigoCupon.Length > 0)
            {
                try
                {
                    new NegocioCupones().Canjear(idNueva, codigoCupon);
                    // El SP recalculo PrecioTotal: releo la reserva para mostrar
                    // el precio ya con el descuento aplicado.
                    Reserva creada = new NegocioReservas().Listar()
                        .FirstOrDefault(x => x.IdReserva == idNueva);
                    decimal precioFinal = creada != null ? creada.PrecioTotal : precio;
                    MostrarResultadoCupon(true, "El descuento ya quedó aplicado en tu reserva.", precioFinal);
                }
                catch (Exception ex)
                {
                    // ex.Message trae el mensaje del THROW del SP. El precio no
                    // cambió, la reserva queda con su total original.
                    MostrarResultadoCupon(false, ex.Message, precio);
                }
            }

            // Alta OK: limpio el formulario y recargo la grilla, la reserva nueva
            // aparece arriba (Listar ordena por fecha descendente).
            LimpiarFormularioNueva();
            CargarReservas(u);
        }

        // Resultado del canje al crear, en un modal centrado para que el cliente
        // lo vea si o si: verde con tilde si se aplicó, amariñlo con alerta si el
        // cupón se rechazó. Siempre muestra el precio con el que quedó la reserva.
        private void MostrarResultadoCupon(bool exito, string mensaje, decimal precioFinal)
        {
            if (exito)
            {
                lblResultadoCuponIcono.Text = "✅";
                lblResultadoCuponTitulo.Text = "¡Cupón aplicado!";
                lblResultadoCuponTitulo.CssClass = "d-block h5 mb-2 text-success";
            }
            else
            {
                lblResultadoCuponIcono.Text = "⚠️";
                lblResultadoCuponTitulo.Text = "El cupón no se aplicó";
                lblResultadoCuponTitulo.CssClass = "d-block h5 mb-2 text-warning";
            }
            lblResultadoCuponMsg.Text = Server.HtmlEncode(mensaje);
            lblResultadoCuponPrecio.Text = string.Format("{0:C0}", precioFinal);

            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalResultadoCupon')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalResultadoCupon", script, true);
        }

        private void MostrarErrorNueva(string mensaje)
        {
            lblErrorNueva.Text = mensaje;
            lblErrorNueva.Visible = true;
            AbrirModalNuevaReserva();
        }

        private void LimpiarFormularioNueva()
        {
            // El combo de cliente solo existe para el mostrador.
            if (!EsCliente) ddlClienteNueva.SelectedValue = "0";
            ddlCanchaNueva.SelectedValue = "0";
            txtFechaNueva.Text = "";
            txtPrecioNueva.Text = "";
            txtObservacionesNueva.Text = "";
            txtCuponNueva.Text = "";
            lblErrorNueva.Visible = false;
            CargarHorariosNueva();
        }

        private void AbrirModalNuevaReserva()
        {
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalNuevaReserva')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalNueva", script, true);
        }

        protected string GetBadgeEstado(object estadoObj)
        {
            EstadoReserva estado = (EstadoReserva)estadoObj;
            switch (estado)
            {
                case EstadoReserva.Nueva:        return "tag tag-ok";
                case EstadoReserva.Reprogramada: return "tag tag-warn";
                case EstadoReserva.Cancelada:    return "tag tag-danger";
                case EstadoReserva.Finalizada:   return "tag tag-info";
                case EstadoReserva.NoAsistio:    return "tag tag-neutral";
                default:                         return "tag tag-neutral";
            }
        }

        protected string GetBadgePago(object pagoObj)
        {
            EstadoPago pago = (EstadoPago)pagoObj;
            switch (pago)
            {
                case EstadoPago.Pagado:      return "tag tag-ok";
                case EstadoPago.Senado:      return "tag tag-info";
                case EstadoPago.Pendiente:   return "tag tag-warn";
                case EstadoPago.Reembolsado: return "tag tag-neutral";
                default:                     return "tag tag-neutral";
            }
        }

        // Texto que ve el usuario. El nombre del enum (Senado) no lleva ñ a
        // propósito: los acentos van en la capa de presentación, no en el identificador.
        protected string GetTextoPago(object pagoObj)
        {
            EstadoPago pago = (EstadoPago)pagoObj;
            switch (pago)
            {
                case EstadoPago.Senado:      return "Señado";
                default:                     return pago.ToString();
            }
        }
    }
}