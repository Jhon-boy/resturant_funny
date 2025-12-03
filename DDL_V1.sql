-- ============================================
-- 1. TABLAS BASE (sin dependencias)
-- ============================================

CREATE TABLE public."TPERSONA" (
  "IDENTIFICACION" character varying NOT NULL,
  "NOMBRES" character varying NOT NULL,
  "APELLIDOS" character varying NOT NULL,
  "FNACIMIENTO" timestamp without time zone,
  "GENERO" character varying,
  "CORREO" character varying,
  "TELEFONO" character varying,
  "DIRECCION" character varying,
  "TIPOIDENTIFICACION" character varying,
  "ESTADO" character varying,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  CONSTRAINT "TPERSONA_pkey" PRIMARY KEY ("IDENTIFICACION")
);

CREATE TABLE public."TSUCURSAL" (
  "IDSUCURSAL" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "NOMBRE" character varying NOT NULL,
  "DIRECCION" character varying NOT NULL,
  "ESTADO" boolean,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  "LATITUD" numeric,
  "LONGITUD" numeric,
  "CONTACTO" character varying,
  CONSTRAINT "TSUCURSAL_pkey" PRIMARY KEY ("IDSUCURSAL")
);

CREATE TABLE public."TROL" (
  "IDROL" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "NOMBRE" character varying NOT NULL,
  "FCREACION" timestamp without time zone NOT NULL,
  "FMODIFICACION" timestamp without time zone,
  "OBSERVACION" character varying,
  "ESTADO" character varying NOT NULL,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  "CODIGO" character varying UNIQUE,
  CONSTRAINT "TROL_pkey" PRIMARY KEY ("IDROL")
);

-- ============================================
-- 2. TABLAS QUE DEPENDEN DE LAS ANTERIORES
-- ============================================

CREATE TABLE public."TUSUARIO" (
  "IDUSUARIO" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDSUCURSAL" integer NOT NULL,
  "IDENTIFICACION" character varying NOT NULL UNIQUE,
  "USUARIO" character varying UNIQUE,
  "PASSWORD" character varying,
  "TEMPORAL" boolean,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  CONSTRAINT "TUSUARIO_pkey" PRIMARY KEY ("IDUSUARIO"),
  CONSTRAINT "TUSUARIO_IDENTIFICACION_fkey" FOREIGN KEY ("IDENTIFICACION") REFERENCES public."TPERSONA"("IDENTIFICACION"),
  CONSTRAINT "TUSUARIO_IDSUCURSAL_fkey" FOREIGN KEY ("IDSUCURSAL") REFERENCES public."TSUCURSAL"("IDSUCURSAL")
);

CREATE TABLE public."TMESA" (
  "IDMESA" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDSUCURSAL" integer,
  "NUMERO" integer,
  "ESTADO" character varying,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  CONSTRAINT "TMESA_pkey" PRIMARY KEY ("IDMESA"),
  CONSTRAINT "TMESA_IDSUCURSAL_fkey" FOREIGN KEY ("IDSUCURSAL") REFERENCES public."TSUCURSAL"("IDSUCURSAL")
);

CREATE TABLE public."TINVENTARIO" (
  "IDINVENTARIO" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDSUCURSAL" integer NOT NULL,
  "NOMBRE" character varying NOT NULL,
  "DESCRIPCION" character varying,
  "CATEGORIA" character varying,
  "STOCK" integer,
  "PRECIO_UNITARIO" numeric,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  "ESTADO" character varying,
  CONSTRAINT "TINVENTARIO_pkey" PRIMARY KEY ("IDINVENTARIO"),
  CONSTRAINT "TINVENTARIO_IDSUCURSAL_fkey" FOREIGN KEY ("IDSUCURSAL") REFERENCES public."TSUCURSAL"("IDSUCURSAL")
);

CREATE TABLE public."TPLANILLA" (
  "IDPLANILLA" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDSUCURSAL" integer NOT NULL,
  "IDENTIFICACION" character varying,
  "PERIODO" character varying,
  "SUELDO_BASE" numeric,
  "COMISION" numeric,
  "BONIFICACION" numeric,
  "DESCUENTO" numeric,
  "TOTAL_PAGAR" numeric,
  "FECHA_PAGO" date,
  "ESTADO" character varying NOT NULL,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  CONSTRAINT "TPLANILLA_pkey" PRIMARY KEY ("IDPLANILLA"),
  CONSTRAINT "TPLANILLA_IDENTIFICACION_fkey" FOREIGN KEY ("IDENTIFICACION") REFERENCES public."TPERSONA"("IDENTIFICACION"),
  CONSTRAINT "TPLANILLA_IDSUCURSAL_fkey" FOREIGN KEY ("IDSUCURSAL") REFERENCES public."TSUCURSAL"("IDSUCURSAL")
);

CREATE TABLE public."TDIRECCION_CLIENTE" (
  "IDDIRECCION" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDENTIFICACION" character varying,
  "NOMBRE_DIRECCION" character varying NOT NULL,
  "DIRECCION" character varying,
  "REFERENCIA" character varying,
  "ES_PRINCIPAL" boolean,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  "ESTADO" character varying NOT NULL,
  CONSTRAINT "TDIRECCION_CLIENTE_pkey" PRIMARY KEY ("IDDIRECCION"),
  CONSTRAINT "TDIRECCION_CLIENTE_IDENTIFICACION_fkey" FOREIGN KEY ("IDENTIFICACION") REFERENCES public."TPERSONA"("IDENTIFICACION")
);

-- ============================================
-- 3. PRODUCTOS + RELACIONES
-- ============================================

CREATE TABLE public."TPRODUCTO" (
  "IDPRODUCTO" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDSUCURSAL" integer NOT NULL,
  "NOMBRE" character varying NOT NULL,
  "DESCRIPCION" character varying NOT NULL,
  "PRECIO" numeric NOT NULL,
  "CATEGORIA" character varying NOT NULL,
  "IMAGEN" character varying,
  "DISPONIBLE" boolean,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  "ESTADO" character varying,
  CONSTRAINT "TPRODUCTO_pkey" PRIMARY KEY ("IDPRODUCTO"),
  CONSTRAINT "TPRODUCTO_IDSUCURSAL_fkey" FOREIGN KEY ("IDSUCURSAL") REFERENCES public."TSUCURSAL"("IDSUCURSAL")
);

CREATE TABLE public."TPRODUCTO_INSUMO" (
  "IDPRODUCTO_INSUMO" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDPRODUCTO" integer NOT NULL,
  "IDINVENTARIO" integer,
  "CANTIDAD" integer,
  CONSTRAINT "TPRODUCTO_INSUMO_pkey" PRIMARY KEY ("IDPRODUCTO_INSUMO"),
  CONSTRAINT "TPRODUCTO_INSUMO_IDINVENTARIO_fkey" FOREIGN KEY ("IDINVENTARIO") REFERENCES public."TINVENTARIO"("IDINVENTARIO"),
  CONSTRAINT "TPRODUCTO_INSUMO_IDPRODUCTO_fkey" FOREIGN KEY ("IDPRODUCTO") REFERENCES public."TPRODUCTO"("IDPRODUCTO")
);

-- ============================================
-- 4. USUARIO - ROL - SESIÓN
-- ============================================

CREATE TABLE public."TROLUSUARIO" (
  "IDROLUSUARIO" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDUSUARIO" integer NOT NULL,
  "IDROL" integer,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  "ESTADO" character varying,
  CONSTRAINT "TROLUSUARIO_pkey" PRIMARY KEY ("IDROLUSUARIO"),
  CONSTRAINT "TROLUSUARIO_IDROL_fkey" FOREIGN KEY ("IDROL") REFERENCES public."TROL"("IDROL"),
  CONSTRAINT "TROLUSUARIO_IDUSUARIO_fkey" FOREIGN KEY ("IDUSUARIO") REFERENCES public."TUSUARIO"("IDUSUARIO")
);

CREATE TABLE public."TSESION" (
  "IDSESION" uuid NOT NULL DEFAULT gen_random_uuid(),
  "IDUSUARIO" integer NOT NULL,
  "TOKEN" uuid NOT NULL UNIQUE,
  "FCREACION" timestamp with time zone DEFAULT now(),
  "FEXPIRACION" timestamp with time zone NOT NULL,
  "ACTIVO" boolean DEFAULT true,
  CONSTRAINT "TSESION_pkey" PRIMARY KEY ("IDSESION"),
  CONSTRAINT "tsesion_idusuario_fkey" FOREIGN KEY ("IDUSUARIO") REFERENCES public."TUSUARIO"("IDUSUARIO")
);

CREATE TABLE public."TDISPOSITIVO" (
  "IDDISPOSITIVO" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDUSUARIO" integer NOT NULL,
  "IMEI" text UNIQUE,
  "MARCA" character varying,
  "MODELO" character varying,
  "ULTIMOACCESO" timestamp without time zone,
  "SISTEMAOPERATIVO" character varying,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  CONSTRAINT "TDISPOSITIVO_pkey" PRIMARY KEY ("IDDISPOSITIVO"),
  CONSTRAINT "TDISPOSITIVO_IDUSUARIO_fkey" FOREIGN KEY ("IDUSUARIO") REFERENCES public."TUSUARIO"("IDUSUARIO")
);

-- ============================================
-- 5. VENTAS (dependen de mesa, usuario, persona)
-- ============================================

CREATE TABLE public."TVENTA" (
  "IDVENTA" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDMESA" integer NOT NULL,
  "CLIENTE" character varying NOT NULL,
  "IDEMPLEADO" integer NOT NULL,
  "TIPO_VENTA" character varying,
  "FECHA" timestamp without time zone,
  "SUBTOTAL" numeric,
  "DELIVERY" numeric,
  "TOTAL" numeric,
  "ESTADO" character varying,
  "CONFACTURA" boolean,
  "COMENTARIO" character varying,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  CONSTRAINT "TVENTA_pkey" PRIMARY KEY ("IDVENTA"),
  CONSTRAINT "TVENTA_IDMESA_fkey" FOREIGN KEY ("IDMESA") REFERENCES public."TMESA"("IDMESA"),
  CONSTRAINT "TVENTA_IDEMPLEADO_fkey" FOREIGN KEY ("IDEMPLEADO") REFERENCES public."TUSUARIO"("IDUSUARIO"),
  CONSTRAINT "TVENTA_CLIENTE_fkey" FOREIGN KEY ("CLIENTE") REFERENCES public."TPERSONA"("IDENTIFICACION")
);

CREATE TABLE public."TDETALLEVENTA" (
  "IDDETALLE" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDVENTA" integer,
  "IDPRODUCTO" integer,
  "CANTIDAD" integer,
  "METODOPAGO" character varying,
  "PRECIO_UNITARIO" numeric,
  "SUBTOTAL" numeric,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  CONSTRAINT "TDETALLEVENTA_pkey" PRIMARY KEY ("IDDETALLE"),
  CONSTRAINT "TDETALLEVENTA_IDVENTA_fkey" FOREIGN KEY ("IDVENTA") REFERENCES public."TVENTA"("IDVENTA"),
  CONSTRAINT "TDETALLEVENTA_IDPRODUCTO_fkey" FOREIGN KEY ("IDPRODUCTO") REFERENCES public."TPRODUCTO"("IDPRODUCTO")
);

-- ============================================
-- 6. FACTURA - ENTREGA - INGRESO/EGRESO
-- ============================================

CREATE TABLE public."TFACTURA" (
  "IDFACTURA" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDVENTA" integer UNIQUE,
  "IDCLIENTE" character varying,
  "NUMEROFACTURA" character varying UNIQUE,
  "FECHA" timestamp without time zone,
  "TOTAL" numeric,
  "COMENTARIO" character varying,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  CONSTRAINT "TFACTURA_pkey" PRIMARY KEY ("IDFACTURA"),
  CONSTRAINT "TFACTURA_IDVENTA_fkey" FOREIGN KEY ("IDVENTA") REFERENCES public."TVENTA"("IDVENTA")
);

CREATE TABLE public."TENTREGA" (
  "IDENTREGA" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDVENTA" integer NOT NULL,
  "IDENTIFICACION_REPARTIDOR" character varying NOT NULL,
  "IDDIRECCION" integer NOT NULL,
  "FECHA_ASIGNACION" timestamp without time zone,
  "FECHA_ENTREGA" timestamp without time zone,
  "ESTADO" character varying,
  "COMENTARIO" character varying,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  CONSTRAINT "TENTREGA_pkey" PRIMARY KEY ("IDENTREGA"),
  CONSTRAINT "TENTREGA_IDVENTA_fkey" FOREIGN KEY ("IDVENTA") REFERENCES public."TVENTA"("IDVENTA"),
  CONSTRAINT "TENTREGA_IDDIRECCION_fkey" FOREIGN KEY ("IDDIRECCION") REFERENCES public."TDIRECCION_CLIENTE"("IDDIRECCION"),
  CONSTRAINT "TENTREGA_IDENTIFICACION_REPARTIDOR_fkey" FOREIGN KEY ("IDENTIFICACION_REPARTIDOR") REFERENCES public."TPERSONA"("IDENTIFICACION")
);

CREATE TABLE public."TINGRESO_EGRESO" (
  "IDMOVIMIENTO" integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  "IDSUCURSAL" integer NOT NULL,
  "TIPO" character varying,
  "CATEGORIA" character varying,
  "DESCRIPCION" character varying,
  "MONTO" numeric,
  "FECHA" timestamp without time zone,
  "REFERENCIA" character varying,
  "ESTADO" character varying,
  "FCREACION" timestamp without time zone,
  "FMODIFICACION" timestamp without time zone,
  "USUARIOINGRESO" character varying,
  "USERMODIFICACION" character varying,
  CONSTRAINT "TINGRESO_EGRESO_pkey" PRIMARY KEY ("IDMOVIMIENTO"),
  CONSTRAINT "TINGRESO_EGRESO_IDSUCURSAL_fkey" FOREIGN KEY ("IDSUCURSAL") REFERENCES public."TSUCURSAL"("IDSUCURSAL")
);
