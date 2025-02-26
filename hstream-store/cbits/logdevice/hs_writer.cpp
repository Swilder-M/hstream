#include "hs_logdevice.h"

facebook::logdevice::Status
_append_payload_sync(logdevice_client_t* client,
                     facebook::logdevice::logid_t logid,
                     // Payload
                     const char* payload, HsInt offset, HsInt length,
                     // Payload End
                     AppendAttributes&& attrs, int64_t* ts, c_lsn_t* lsn_ret) {
  c_lsn_t result;
  if (ts) {
    std::chrono::milliseconds timestamp;
    result = client->rep->appendSync(logid, Payload(payload + offset, length),
                                     attrs, &timestamp);
    *ts = timestamp.count();
  } else {
    result = client->rep->appendSync(facebook::logdevice::logid_t(logid),
                                     Payload(payload + offset, length), attrs,
                                     nullptr);
  }

  if (result == facebook::logdevice::LSN_INVALID) {
    return facebook::logdevice::err;
  }
  *lsn_ret = result;
  return facebook::logdevice::E::OK;
}

facebook::logdevice::Status _append_payload_async(
    HsStablePtr mvar, HsInt cap, logdevice_append_cb_data_t* cb_data,
    logdevice_client_t* client, facebook::logdevice::logid_t logid,
    // Payload
    const char* payload, HsInt offset, HsInt length,
    // Payload End
    AppendAttributes&& attrs) {
  auto cb = [cb_data, mvar, cap](facebook::logdevice::Status st,
                                 const DataRecord& r) {
    if (cb_data) {
      cb_data->st = static_cast<c_error_code_t>(st);
      cb_data->logid = r.logid.val_;
      cb_data->lsn = r.attrs.lsn;
      cb_data->timestamp = r.attrs.timestamp.count();
    }
    hs_try_putmvar(cap, mvar);
  };
  int ret = client->rep->append(logid, Payload(payload + offset, length),
                                std::move(cb), attrs);
  if (ret == 0)
    return facebook::logdevice::E::OK;
  return facebook::logdevice::err;
}

extern "C" {
// ----------------------------------------------------------------------------

void ld_cons_append_attributes(AppendAttributes* attrs, KeyType* keytypes,
                               const char** keyvals, HsInt optional_keys_len,
                               uint8_t* counter_key, int64_t* counter_val,
                               HsInt counters_len) {
  std::map<KeyType, std::string> optional_keys;
  if (optional_keys_len > 0) {
    for (int i = 0; i < optional_keys_len; ++i) {
      optional_keys[keytypes[i]] = keyvals[i];
    }
  }

  folly::Optional<std::map<uint8_t, int64_t>> counters = folly::none;
  if (counters_len >= 0) {
    std::map<uint8_t, int64_t> counters_map;
    for (int i = 0; i < counters_len; ++i) {
      counters_map[counter_key[i]] = counter_val[i];
    }
    counters = counters_map;
  }

  attrs->optional_keys = optional_keys;
  attrs->counters = counters;
}

AppendAttributes*
ld_new_append_attributes(KeyType* keytypes, const char** keyvals,
                         HsInt optional_keys_len, uint8_t* counter_key,
                         int64_t* counter_val, HsInt counters_len) {
  AppendAttributes* attrs = new AppendAttributes;
  ld_cons_append_attributes(attrs, keytypes, keyvals, optional_keys_len,
                            counter_key, counter_val, counters_len);
  return attrs;
}

void ld_free_append_attributes(AppendAttributes* attrs) { delete attrs; }

facebook::logdevice::Status
logdevice_append_async(logdevice_client_t* client, c_logid_t logid,
                       // payload
                       const char* payload, HsInt offset, HsInt length,
                       // cb
                       HsStablePtr mvar, HsInt cap,
                       logdevice_append_cb_data_t* cb_data) {
  return _append_payload_async(mvar, cap, cb_data, client, logid_t(logid),
                               payload, offset, length, AppendAttributes());
}

facebook::logdevice::Status logdevice_append_with_attrs_async(
    logdevice_client_t* client, c_logid_t logid,
    // payload
    const char* payload, HsInt offset, HsInt length,
    // attr
    KeyType keytype, const char* keyval,
    // cb
    HsStablePtr mvar, HsInt cap, logdevice_append_cb_data_t* cb_data) {
  AppendAttributes attrs;
  attrs.optional_keys[keytype] = keyval;
  return _append_payload_async(mvar, cap, cb_data, client, logid_t(logid),
                               payload, offset, length, std::move(attrs));
}

#if __GLASGOW_HASKELL__ < 810
facebook::logdevice::Status logdevice_append_batch(
    logdevice_client_t* client, c_logid_t logid,
    // Payloads
    StgMutArrPtrs* payloads_, HsInt* payload_lens, HsInt total_len,
    c_compression_t compression, HsInt zstd_level,
    // attr
    KeyType keytype, const char* keyval,
    //
    HsStablePtr mvar, HsInt cap, logdevice_append_cb_data_t* cb_data) {
  StgArrBytes** payloads = (StgArrBytes**)payloads_->payload;
#else
facebook::logdevice::Status logdevice_append_batch(
    logdevice_client_t* client, c_logid_t logid,
    // Payloads
    StgArrBytes** payloads, HsInt* payload_lens, HsInt total_len,
    c_compression_t compression, HsInt zstd_level,
    // attr
    KeyType keytype, const char* keyval,
    //
    HsStablePtr mvar, HsInt cap, logdevice_append_cb_data_t* cb_data) {
#endif
  BufferedWriteCodec::Estimator blob_size_estimator;
  for (int i = 0; i < total_len; ++i) {
    auto iobuf = folly::IOBuf::wrapBufferAsValue((char*)payloads[i]->payload,
                                                 (HsInt)payload_lens[i]);
    blob_size_estimator.append(iobuf);
  }
  const size_t total_blob_bytes =
      blob_size_estimator.calculateSize(/* checksum_bits */ 0);
  BufferedWriteCodec::Encoder<BufferedWriteSinglePayloadsCodec::Encoder>
      encoder(/* checksum_bits */ 0, total_len, total_blob_bytes);

  for (int i = 0; i < total_len; ++i) {
    encoder.append(folly::IOBuf::wrapBufferAsValue((char*)payloads[i]->payload,
                                                   (HsInt)payload_lens[i]));
  }

  folly::IOBufQueue encoded;
  encoder.encode(encoded, Compression(compression), zstd_level);
  folly::IOBuf blob = encoded.moveAsValue();

  PayloadHolder payload_holder;
  payload_holder = PayloadHolder(std::move(blob));

  auto cb = [cb_data, mvar, cap](facebook::logdevice::Status st,
                                 const DataRecord& r) {
    if (cb_data) {
      cb_data->st = static_cast<c_error_code_t>(st);
      cb_data->logid = r.logid.val_;
      cb_data->lsn = r.attrs.lsn;
      cb_data->timestamp = r.attrs.timestamp.count();
    }
    hs_try_putmvar(cap, mvar);
  };

  AppendAttributes attrs;
  if (keytype != KeyType::UNDEFINED) {
    attrs.optional_keys[keytype] = keyval;
  }

  ClientImpl* client_impl = dynamic_cast<ClientImpl*>(client->rep.get());
  int rv = client_impl->appendBatched(logid_t(logid), std::move(payload_holder),
                                      cb, std::move(attrs), worker_id_t{-1});
  if (rv == 0)
    return facebook::logdevice::E::OK;
  return facebook::logdevice::err;
}

facebook::logdevice::Status logdevice_append_batch_safe(
    logdevice_client_t* client, c_logid_t logid,
    // Payloads
    char** payloads, int* payload_lens, HsInt total_len,
    c_compression_t compression, HsInt zstd_level,
    // attr
    KeyType keytype, const char* keyval,
    HsStablePtr mvar, HsInt cap, logdevice_append_cb_data_t* cb_data) {

  auto cb = [cb_data, mvar, cap](facebook::logdevice::Status st,
                                 const DataRecord& r) {
    if (cb_data) {
      cb_data->st = static_cast<c_error_code_t>(st);
      cb_data->logid = r.logid.val_;
      cb_data->lsn = r.attrs.lsn;
      cb_data->timestamp = r.attrs.timestamp.count();
    }
    hs_try_putmvar(cap, mvar);
  };

  AppendAttributes attrs;
  if (keytype != KeyType::UNDEFINED) {
    attrs.optional_keys[keytype] = keyval;
  }

  int rv = client->rep->appendBatched(logid_t(logid), payloads, payload_lens,
                                      total_len, cb, Compression(compression),
                                      zstd_level, std::move(attrs));
  if (rv == 0)
    return facebook::logdevice::E::OK;
  return facebook::logdevice::err;
}

// ----------------------------------------------------------------------------

[[deprecated]] facebook::logdevice::Status
logdevice_append_with_attrs_sync(logdevice_client_t* client, c_logid_t logid,
                                 // Payload
                                 const char* payload, HsInt offset,
                                 HsInt length,
                                 // Payload End
                                 // optional_key
                                 KeyType keytype, const char* keyval,
                                 // OptionalKey End
                                 c_timestamp_t* ts, c_lsn_t* lsn_ret) {
  AppendAttributes attrs;
  attrs.optional_keys[keytype] = keyval;
  return _append_payload_sync(client, logid_t(logid), payload, offset, length,
                              std::move(attrs), ts, lsn_ret);
}

[[deprecated]] facebook::logdevice::Status
logdevice_append_sync(logdevice_client_t* client, c_logid_t logid,
                      // Payload
                      const char* payload, HsInt offset, HsInt length,
                      // Payload End
                      c_timestamp_t* ts, c_lsn_t* lsn_ret) {
  return _append_payload_sync(client, logid_t(logid), payload, offset, length,
                              AppendAttributes(), ts, lsn_ret);
}

// ----------------------------------------------------------------------------
} // end extern "C"
